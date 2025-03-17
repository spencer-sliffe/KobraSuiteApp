"""
------------------Prologue--------------------
File Name: task_utils.py
Path: kobrasuitecore/hq/utils/task_utils.py

Date Created:
"About a week ago" - Bob S.

Date Updated:
2025-03-16

Description:
Defines utility functions for dealing with the backend task handling system, including:
- applying task rewards
- calculating task performance
- allocating and deallocating task slots

Input:
Varies by utility function

Output:


Collaborators: JAKE BERNARD, SPENCER SLIFFE, CHATGPT from "OPEN"AI
---------------------------------------------
"""
# importing python libs
import datetime
import json
import logging
import math
import random

# importing django stuff
from django.utils import timezone

# importing our stuff
from hq.models import TaskCategoryProgress, TaskCategorySlots, TaskPerformanceBounds, ModuleExperience, ModuleStatus, \
    ModulePopulation, Wallet, UserProfile
from ...kobrasuitecore.task_config.task_map import TaskMap

# setting up logger
logger = logging.getLogger(__name__)

# TODO: (JAKE, TASK UTILS) Have this return BadRequest in certain scenarios
def apply_task_rewards(profile, module, category_id, task_slot_id, data):
    progress, created = TaskCategoryProgress.objects.get_or_create(
        profile=profile,
        module=module,
        category_id=category_id
    )

    now = timezone.now()
    cat_config = get_category_config(module, category_id)
    if not cat_config:
        return no_completion_response()

    slot_limit, completion_limit, renewal_period, eval_func = cat_config
    is_unique = slot_limit > 0



    slots = None
    # IMPORTANT
    # bad outcome: unique tasks need an allocated slot before they can be accomplished
    if created and is_unique:
        # TODO: (JAKE, TASK UTILS) Should this be critical?(1)
        # this should never happen
        logger.critical(f"Unique Task from Module {module} with ID {category_id}"
                        f" was asking for completion before creation.")
        return no_completion_response()
    elif is_unique:
        slots = TaskCategorySlots.objects.get(progress=progress)
        if not slots:
            # TODO: (JAKE, TASK UTILS) Should this be critical?(2)
            logger.critical(f"Unique Task from Module {module} with ID {category_id}"
                            f" was created with no slots but is asking for completion.")
            return no_completion_response()

    reset_if_renewed(progress, slot_limit, renewal_period, slots, now)

    if is_unique:
        if task_slot_id < 0 or task_slot_id >= slot_limit:
            return no_completion_response()
        if not is_slot_allocated(task_slot_id, slots):
            return no_completion_response()
        if was_already_completed(task_slot_id, slots):
            return no_completion_response()

    task_completed = True
    performance = calculate_performance(progress, task_slot_id, eval_func, data)
    category_over_limit = progress.completion_count >= completion_limit

    has_reward = not category_over_limit and not category_id == 0
    currency, experience, population = 0, 0, 0
    has_ranked_up = False

    if has_reward:
        base_currency   = random.randint(5, 10) * profile.multiplier()
        base_population = (random.choices([0,1,2], [20,2,1])[0]
                           * profile.multiplier())
        base_experience = random.randint(1,3) * profile.multiplier()
        currency = int(base_currency * performance)
        experience = int(base_experience * performance)
        population = int(base_population * performance)

        add_currency_to_wallet(profile, currency)
        update_population(profile, module, population)
        old_module_experience = update_experience(profile, module, experience)

        inc_completion_count(progress)

        has_ranked_up = check_rank_up(profile, experience, old_module_experience)

        if is_unique:
            mark_slot_completed(task_slot_id, slots)
    elif category_id == 0:
        inc_completion_count(progress)
        if progress.completion_count < 1:
            update_streak(profile, module)
    else:
        inc_completion_count(progress)

    return {
        "task_completed": task_completed,
        "has_reward": has_reward,
        "has_ranked_up": has_ranked_up,
        "performance": performance,
        "currency": currency,
        "experience": experience,
        "population": population
    }


def no_completion_response():
    return {
        "task_completed": False,
        "has_reward": False,
        "has_ranked_up": False,
        "performance": 1.0,
        "currency": 0,
        "experience": 0,
        "population": 0
    }


def inc_completion_count(progress):
    current = progress.completion_count
    if current >= 2147483647:
        return
    progress.completion_count = current + 1
    progress.save()


def reset_if_renewed(progress, slot_limit, renewal_period, slots, now):
    days_diff = (now - progress.last_renewed_at).days
    if days_diff >= renewal_period:
        progress.completion_count = 0
        progress.last_renewed_at = now
        progress.save()
        if slot_limit > 0 and slots:
            slots.update(completed=0)


def get_category_config(module, category_id):
    cat = TaskMap.get(module, {}).get(category_id, None)
    if not cat:
        logger.critical(f"Failed to get config for task from module {module} with ID {category_id}")
        return None
    return (
        cat.get('slot_limit', 0),
        cat.get('completion_limit', 1),
        cat.get('renewal_period', 1),
        cat.get('eval_func')
    )


def is_slot_allocated(task_slot_id, slots):
    return slots.slots & (1 << task_slot_id) != 0


def was_already_completed(task_slot_id, slots):
    return slots.completed & (1 << task_slot_id) != 0


def mark_slot_completed(task_slot_id, slots):
    slots.completed = slots.completed | (1 << task_slot_id)
    slots.save()


def calculate_performance(progress, task_slot_id, eval_func, data):
    if not eval_func:
        return 1.0

    task_bounds = TaskPerformanceBounds.objects.filter(progress=progress, slot_index=task_slot_id).first()
    # TODO: (JAKE, TASK UTILS) Maybe make sure the backend data is formatted correctly for performance bounds
    task_bounds = json.loads(task_bounds.data) if task_bounds else None
    try:
        frontend_data = json.loads(data) if data else None
    except:
        # TODO: (JAKE, TASK UTILS) Log when the frontend data is not formatted correctly or probably just return BadRequest
        frontend_data = None

    performance = 1.0
    if eval_func:
        performance = eval_func(frontend_data, task_bounds)

    return performance if performance is not None else 1.0


def check_rank_up(profile, gained_xp, before_module):

    before = profile.experience()
    after = before + gained_xp
    old_rank = math.floor(math.log2(before + 1)) if before > 0 else 0
    new_rank = math.floor(math.log2(after + 1)) if after > 0 else 0

    return new_rank > old_rank

def default_eval():
    return 1.0

def add_currency_to_wallet(profile, amount):
    wallet = profile.wallet.first()
    if not wallet:
        wallet = Wallet.objects.create(profile=profile)
    wallet.balance += int(amount)
    wallet.save()


def update_experience(profile, module, amount):
    experience_obj, _ = ModuleExperience.objects.get_or_create(profile=profile, module_type=module)
    old_module_experience = experience_obj.experience_amount
    experience_obj.experience_amount += amount
    experience_obj.save()
    return old_module_experience


def update_streak(profile, module):
    today = timezone.now().date()
    status_obj, _ = ModuleStatus.objects.get_or_create(profile=profile, module_type=module)

    if status_obj.streak_start is None or status_obj.current_streak == 0:
        status_obj.streak_start = today
        status_obj.current_streak = 1
    else:
        last_streak_day = status_obj.streak_start + datetime.timedelta(days=status_obj.current_streak - 1)
        if today == last_streak_day + datetime.timedelta(days=1):
            status_obj.current_streak += 1
        else:
            status_obj.streak_start = today
            status_obj.current_streak = 1
    if status_obj.current_streak > status_obj.max_streak:
        status_obj.max_streak = status_obj.current_streak
    if status_obj.max_streak > status_obj.building_level:
        status_obj.building_level = status_obj.max_streak
    status_obj.save()

def update_population(profile, module, population_gain):
    population_obj, _ = ModulePopulation.objects.get_or_create(profile=profile, module_type=module)
    population_obj.population += population_gain
    population_obj.population = max(population_obj.population, 0)
    population_obj.save()

def alloc_task_slot(profile, module, task_category_id):
    slot_limit = TaskMap[module][task_category_id]['slot_limit']

    if slot_limit == 0:
        return False, 0

    task_category_progress = (TaskCategoryProgress
                              .objects
                              .filter(profile=profile,
                                      module=module,
                                      task_category_id=task_category_id)
                              .first())
    task_slots, _ = (TaskCategorySlots
                .objects.get_or_create(progress=task_category_progress))

    slots = task_slots.slots

    for i in range(slot_limit):
        if not slots & (1 << i):
            task_slots.slots = task_slots.slots | (1 << i)
            task_slots.save()
            return True, i

    return False, slot_limit + 1

def dealloc_task_slot(profile, module, task_category_id, slot_id):
    slot_limit = TaskMap[module][task_category_id]['slot_limit']

    if slot_id > slot_limit or slot_id < 0:
        return False

    task_category_progress = (TaskCategoryProgress
                              .objects
                              .filter(profile=profile,
                                      module=module,
                                      task_category_id=task_category_id)
                              .first())
    task_slots, _ = (TaskCategorySlots
                .objects.get_or_create(progress=task_category_progress))

    task_slots.slots = task_slots.slots & ~(1 << task_category_id)
    task_slots.save()

    return True
