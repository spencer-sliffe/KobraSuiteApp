from django.utils import timezone
import datetime
import math
from hq.models import TaskCategoryProgress, TaskCategorySlot, TaskPerformanceBounds


def apply_task_rewards(task):
    now = timezone.now()
    profile = task.profile
    module = task.module
    category_id = task.category_id
    unique_id = task.unique_task_id
    cat_config = get_category_config(module, category_id)
    if not cat_config:
        return no_completion_response()

    slot_limit, completion_limit, renewal_period, eval_func_name = cat_config
    is_unique = slot_limit > 0

    progress, _ = TaskCategoryProgress.objects.get_or_create(
        profile=profile,
        module=module,
        category_id=category_id
    )

    reset_if_renewed(progress, slot_limit, renewal_period)

    if is_unique:
        if unique_id is None or unique_id < 0 or unique_id >= slot_limit:
            return no_completion_response()
        if not is_slot_allocated(progress, unique_id):
            return no_completion_response()
        if was_already_completed(progress, unique_id):
            return no_completion_response()

    task_completed = True
    performance = calculate_performance(progress, unique_id, eval_func_name, task)
    category_over_limit = progress.completion_count >= completion_limit

    has_reward = not category_over_limit
    currency, experience, population, has_ranked_up = 0, 0, 0, False

    if has_reward:
        base_currency = 10
        base_experience = 5
        base_population = 1
        currency = int(base_currency * performance)
        experience = max(1, int(base_experience * performance))
        population = int(base_population * performance)
        inc_completion_count(progress)
        has_ranked_up = check_rank_up(profile, experience)
        if is_unique:
            mark_slot_completed(progress, unique_id)
    else:
        inc_completion_count(progress, saturate_only=True)

    return (
        currency,
        experience,
        population,
        task_completed,
        has_reward,
        performance,
        has_ranked_up
    )


def no_completion_response():
    return (0, 0, 0, False, False, 1.0, False)


def inc_completion_count(progress, saturate_only=False):
    current = progress.completion_count
    if saturate_only and current >= 2147483647:
        return
    progress.completion_count = min(current + 1, 2147483647)
    progress.save()


def reset_if_renewed(progress, slot_limit, renewal_period):
    now = timezone.now()
    days_diff = (now - progress.last_renewed_at).days
    if days_diff >= renewal_period:
        progress.completion_count = 0
        progress.last_renewed_at = now
        progress.save()
        if slot_limit > 0:
            TaskCategorySlot.objects.filter(progress=progress).update(completed=False)


def get_category_config(module, category_id):
    config_map = {
        'F': {
            0: {'slot_limit': 0, 'limit': 12, 'renewal': 1, 'eval_func': 'some_finance_eval'},
        },
        'H': {
            0: {'slot_limit': 12, 'limit': 6, 'renewal': 1, 'eval_func': None},
        },
        'S': {},
        'W': {}
    }
    cat = config_map.get(module, {}).get(category_id)
    if not cat:
        return None
    return (
        cat.get('slot_limit', 0),
        cat.get('limit', 1),
        cat.get('renewal', 1),
        cat.get('eval_func')
    )


def is_slot_allocated(progress, unique_id):
    try:
        slot = TaskCategorySlot.objects.get(progress=progress, slot_index=unique_id)
        return slot.allocated
    except TaskCategorySlot.DoesNotExist:
        return False


def was_already_completed(progress, unique_id):
    try:
        slot = TaskCategorySlot.objects.get(progress=progress, slot_index=unique_id)
        return slot.completed
    except TaskCategorySlot.DoesNotExist:
        return False


def mark_slot_completed(progress, unique_id):
    try:
        slot = TaskCategorySlot.objects.get(progress=progress, slot_index=unique_id)
        slot.completed = True
        slot.save()
    except TaskCategorySlot.DoesNotExist:
        pass


def calculate_performance(progress, unique_id, eval_func_name, task):
    data_record = None
    if unique_id is not None:
        data_record = TaskPerformanceBounds.objects.filter(progress=progress, slot_index=unique_id).first()
    else:
        data_record = TaskPerformanceBounds.objects.filter(progress=progress, slot_index=-1).first()

    if not data_record and not eval_func_name:
        return 1.0

    performance_data = 1.0
    if eval_func_name:
        performance_data = run_eval_function(eval_func_name, data_record, task)

    return performance_data or 1.0


def run_eval_function(func_name, data_record, task):
    # Placeholder for hooking up actual evaluation logic
    # For demonstration, always returns 1.0
    return 1.0


def check_rank_up(profile, gained_xp):
    before = profile.experience()
    after = before + gained_xp
    old_rank = math.floor(math.log2(before + 1)) if before > 0 else 0
    new_rank = math.floor(math.log2(after + 1)) if after > 0 else 0
    return new_rank > old_rank


from django.utils import timezone
import datetime
import math
from hq.models import TaskCategoryProgress, TaskCategorySlot, TaskPerformanceBounds

def run_eval_function(func_name, data_record, task):
    data_from_bounds = data_record.data if data_record else {}
    data_from_task = {
        "task_weight": task.task_weight,
        "date": str(task.date)
    }
    eval_func = EVALUATION_FUNCTIONS.get(func_name, default_eval)
    return eval_func(data_from_bounds, data_from_task)

def default_eval(bounds_data, task_data):
    return 1.0

def some_finance_eval(bounds_data, task_data):
    budget = bounds_data.get("budget", 100)
    expense = task_data.get("expense", 0)
    if expense <= 0:
        return 1.0
    ratio = budget / expense
    return ratio if ratio < 1.5 else 1.5

def some_homelife_eval(bounds_data, task_data):
    due_date = bounds_data.get("due_date")
    now_str = task_data.get("date")
    if not due_date or not now_str:
        return 1.0
    now_date = datetime.datetime.strptime(now_str, "%Y-%m-%d").date()
    due_date_obj = datetime.datetime.strptime(due_date, "%Y-%m-%d").date()
    days_early = (due_date_obj - now_date).days
    return 1.2 if days_early > 0 else 1.0

EVALUATION_FUNCTIONS = {
    "some_finance_eval": some_finance_eval,
    "some_homelife_eval": some_homelife_eval
}