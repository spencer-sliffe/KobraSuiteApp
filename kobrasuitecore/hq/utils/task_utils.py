"""
------------------Prologue--------------------
File Name: task_utils.py
Path: kobrasuitecore/hq/utils/task_utils.py

Date Created:
2025-03-08

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
from hq.task_config.task_map import TaskMap

# setting up logger
logger = logging.getLogger(__name__)

# TODO: (JAKE, TASK UTILS) Have this return BadRequest in certain scenarios
def apply_task_rewards(profile, module, category_id, task_slot_id, data):
    # (TEMP) Get or create progress record for user's task category
    progress, created = TaskCategoryProgress.objects.get_or_create(
        profile=profile,
        module=module,
        category_id=category_id
    )

    # (TEMP) Get current time
    now = timezone.now()
    # (TEMP) Retrieve category configuration parameters
    cat_config = get_category_config(module, category_id)
    # (TEMP) Return failure if config not found
    if not cat_config:
        return no_completion_response()

    # (TEMP) Unpack configuration parameters
    slot_limit, completion_limit, renewal_period, eval_func = cat_config
    # (TEMP) Determine if task requires unique slot allocation
    is_unique = slot_limit > 0

    # (TEMP) Get associated task slots (for unique tasks)
    slots = None
    # IMPORTANT
    # bad outcome: unique tasks need an allocated slot before they can be accomplished
    # (TEMP) Handle edge case where unique task is completed before creation
    if created and is_unique:
        # TODO: (JAKE, TASK UTILS) Should this be critical?(1)
        # this should never happen
        logger.critical(f"Unique Task from Module {module} with ID {category_id}"
                        f" was asking for completion before creation.")
        return no_completion_response()
    elif is_unique:
        # (TEMP) Retrieve existing task slots record
        slots = TaskCategorySlots.objects.get(progress=progress)
        if not slots:
            # TODO: (JAKE, TASK UTILS) Should this be critical?(2)
            logger.critical(f"Unique Task from Module {module} with ID {category_id}"
                            f" was created with no slots but is asking for completion.")
            return no_completion_response()

    # (TEMP) Check if task needs renewal-based reset
    reset_if_renewed(progress, slot_limit, renewal_period, slots, now)

    # (TEMP) Validate slot ID for unique tasks
    if is_unique:
        if task_slot_id < 0 or task_slot_id >= slot_limit:
            return no_completion_response()
        if not is_slot_allocated(task_slot_id, slots):
            return no_completion_response()
        if was_already_completed(task_slot_id, slots):
            return no_completion_response()

    # (TEMP) Assume task completion unless blocked
    task_completed = True
    # (TEMP) Calculate performance multiplier based on evaluation function
    performance = calculate_performance(progress, task_slot_id, eval_func, data)
    # (TEMP) Check if category completion limit reached
    category_over_limit = progress.completion_count >= completion_limit

    # (TEMP) Determine if reward should be granted
    has_reward = not category_over_limit and not category_id == 0
    # (TEMP) Initialize reward containers
    currency, experience, population = 0, 0, 0
    has_ranked_up = False

    if has_reward:
        # (TEMP) Generate base rewards using random values and profile multipliers
        base_currency   = random.randint(5, 10) * profile.multiplier()
        base_population = (random.choices([0,1,2], [20,2,1])[0]
                           * profile.multiplier())
        base_experience = random.randint(1,3) * profile.multiplier()
        # (TEMP) Apply performance multiplier to rewards
        currency = int(base_currency * performance)
        experience = int(base_experience * performance)
        population = int(base_population * performance)

        # (TEMP) Update user wallet with currency reward
        add_currency_to_wallet(profile, currency)
        # (TEMP) Update module population with gain
        update_population(profile, module, population)
        # (TEMP) Update experience and check for rank up
        old_module_experience = update_experience(profile, module, experience)

        # (TEMP) Increment completion counter
        inc_completion_count(progress)

        # (TEMP) Check if rank increased due to new experience
        has_ranked_up = check_rank_up(profile, experience, old_module_experience)

        # (TEMP) Mark unique task slot as completed
        if is_unique:
            mark_slot_completed(task_slot_id, slots)
    elif category_id == 0:
        # (TEMP) Handle non-rewarded base category completion
        inc_completion_count(progress)
        if progress.completion_count < 1:
            # (TEMP) Update streak for first-time completion
            update_streak(profile, module)
    else:
        # (TEMP) Increment counter for non-unique tasks
        inc_completion_count(progress)

    # (TEMP) Return final results package
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
    # (TEMP) Return default failure response
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
    # (TEMP) Get current completion count
    current = progress.completion_count
    # (TEMP) Prevent overflow beyond 32-bit integer limit
    if current >= 2147483647:
        return
    # (TEMP) Increment and save progress
    progress.completion_count = current + 1
    progress.save()

def reset_if_renewed(progress, slot_limit, renewal_period, slots, now):
    # (TEMP) Calculate days since last renewal
    days_diff = (now - progress.last_renewed_at).days
    # (TEMP) Reset progress if renewal period expired
    if days_diff >= renewal_period:
        progress.completion_count = 0
        progress.last_renewed_at = now
        progress.save()
        # (TEMP) Reset unique task slots if applicable
        if slot_limit > 0 and slots:
            slots.update(completed=0)

def get_category_config(module, category_id):
    # (TEMP) Retrieve configuration from task map
    cat = TaskMap.get(module, {}).get(category_id, None)
    # (TEMP) Log error and return if missing
    if not cat:
        logger.critical(f"Failed to get config for task from module {module} with ID {category_id}")
        return None
    # (TEMP) Extract configuration parameters
    return (
        cat.get('slot_limit', 0),
        cat.get('completion_limit', 1),
        cat.get('renewal_period', 1),
        cat.get('eval_func')
    )

def is_slot_allocated(task_slot_id, slots):
    # (TEMP) Check if slot is allocated using bitmask
    return slots.slots & (1 << task_slot_id) != 0

def was_already_completed(task_slot_id, slots):
    # (TEMP) Check if slot was already completed using bitmask
    return slots.completed & (1 << task_slot_id) != 0

def mark_slot_completed(task_slot_id, slots):
    # (TEMP) Set completion bit in bitmask
    slots.completed = slots.completed | (1 << task_slot_id)
    slots.save()

def calculate_performance(progress, task_slot_id, eval_func, data):
    # (TEMP) Default to 1.0 if no evaluator
    if not eval_func:
        return 1.0

    # (TEMP) Get stored performance bounds for this task slot
    task_bounds = TaskPerformanceBounds.objects.filter(progress=progress, slot_index=task_slot_id).first()
    # (TEMP) Parse stored bounds data
    task_bounds = json.loads(task_bounds.data) if task_bounds else None
    try:
        # (TEMP) Parse incoming data from frontend
        frontend_data = json.loads(data) if data else None
    except:
        # (TEMP) Handle invalid data format
        # TODO: (JAKE, TASK UTILS) Log when the frontend data is not formatted correctly or probably just return BadRequest
        frontend_data = None

    # (TEMP) Initialize default performance
    performance = 1.0
    if eval_func:
        # (TEMP) Execute evaluation function with data
        performance = eval_func(frontend_data, task_bounds)

    # (TEMP) Ensure valid performance value
    return performance if performance is not None else 1.0

def check_rank_up(profile, gained_xp, before_module):
    # (TEMP) Calculate old and new rank levels
    before = profile.experience()
    after = before + gained_xp
    old_rank = math.floor(math.log2(before + 1)) if before > 0 else 0
    new_rank = math.floor(math.log2(after + 1)) if after > 0 else 0

    # (TEMP) Return true if rank increased
    return new_rank > old_rank

def default_eval():
    # (TEMP) Default evaluation returns base multiplier
    return 1.0

def add_currency_to_wallet(profile, amount):
    # (TEMP) Get or create user wallet
    wallet = profile.wallet.first()
    if not wallet:
        wallet = Wallet.objects.create(profile=profile)
    # (TEMP) Add currency and save
    wallet.balance += int(amount)
    wallet.save()

def update_experience(profile, module, amount):
    # (TEMP) Get or create module experience record
    experience_obj, _ = ModuleExperience.objects.get_or_create(profile=profile, module_type=module)
    # (TEMP) Record previous experience value
    old_module_experience = experience_obj.experience_amount
    # (TEMP) Update and save new experience
    experience_obj.experience_amount += amount
    experience_obj.save()
    return old_module_experience

def update_streak(profile, module):
    # (TEMP) Get current date and module status
    today = timezone.now().date()
    status_obj, _ = ModuleStatus.objects.get_or_create(profile=profile, module_type=module)

    # (TEMP) Initialize streak if needed
    if status_obj.streak_start is None or status_obj.current_streak == 0:
        status_obj.streak_start = today
        status_obj.current_streak = 1
    else:
        # (TEMP) Check consecutive days
        last_streak_day = status_obj.streak_start + datetime.timedelta(days=status_obj.current_streak - 1)
        if today == last_streak_day + datetime.timedelta(days=1):
            status_obj.current_streak += 1
        else:
            status_obj.streak_start = today
            status_obj.current_streak = 1
    # (TEMP) Update max streak and building level
    if status_obj.current_streak > status_obj.max_streak:
        status_obj.max_streak = status_obj.current_streak
    if status_obj.max_streak > status_obj.building_level:
        status_obj.building_level = status_obj.max_streak
    status_obj.save()

def update_population(profile, module, population_gain):
    # (TEMP) Get or create module population record
    population_obj, _ = ModulePopulation.objects.get_or_create(profile=profile, module_type=module)
    # (TEMP) Apply population change with minimum 0
    population_obj.population += population_gain
    population_obj.population = max(population_obj.population, 0)
    population_obj.save()

def alloc_task_slot(profile, module, task_category_id):
    # (TEMP) Get slot limit from configuration
    slot_limit = TaskMap[module][task_category_id]['slot_limit']

    # (TEMP) Return failure if no slots available
    if slot_limit == 0:
        return False, 0

    # (TEMP) Get existing progress record
    task_category_progress = (TaskCategoryProgress
                              .objects
                              .filter(profile=profile,
                                      module=module,
                                      task_category_id=task_category_id)
                              .first())
    # (TEMP) Get or create associated slots record
    task_slots, _ = (TaskCategorySlots
                .objects.get_or_create(progress=task_category_progress))

    # (TEMP) Iterate through slots to find first available
    slots = task_slots.slots
    for i in range(slot_limit):
        if not slots & (1 << i):
            # (TEMP) Mark slot as allocated and return
            task_slots.slots = task_slots.slots | (1 << i)
            task_slots.save()
            return True, i

    # (TEMP) Return failure if no slots available
    return False, slot_limit + 1

def dealloc_task_slot(profile, module, task_category_id, slot_id):
    # (TEMP) Validate slot ID
    slot_limit = TaskMap[module][task_category_id]['slot_limit']

    if slot_id > slot_limit or slot_id < 0:
        return False

    # (TEMP) Get existing progress record
    task_category_progress = (TaskCategoryProgress
                              .objects
                              .filter(profile=profile,
                                      module=module,
                                      task_category_id=task_category_id)
                              .first())
    # (TEMP) Get associated slots record
    task_slots, _ = (TaskCategorySlots
                .objects.get_or_create(progress=task_category_progress))

    # (TEMP) Clear the allocated bit in bitmask
    task_slots.slots = task_slots.slots & ~(1 << task_category_id)
    task_slots.save()

    # (TEMP) Return success
    return True
