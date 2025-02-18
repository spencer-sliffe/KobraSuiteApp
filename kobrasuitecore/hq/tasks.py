# hq/tasks.py
import datetime
import math
import random
from django.utils import timezone
from .models import ModuleExperience, ModuleStatus, ModulePopulation, Wallet


def apply_task_rewards(module_task):
    profile = getattr(module_task.user, 'profile', None)
    if not profile:
        return
    currency_gain = random.randint(5, 10) * profile.multiplier() * module_task.task_weight
    add_currency_to_wallet(profile, currency_gain)
    if module_task.task_number != 0:
        experience_gain = module_task.task_weight * profile.multiplier()
        update_experience(profile, module_task.module, experience_gain)
        update_streak_and_population(profile, module_task.module)


def add_currency_to_wallet(profile, amount):
    wallet = profile.wallet.first()
    if not wallet:
        wallet = Wallet.objects.create(profile=profile)
    wallet.balance += int(amount)
    wallet.save()


def update_experience(profile, module, amount):
    experience_obj, _ = ModuleExperience.objects.get_or_create(profile=profile, module_type=module)
    experience_obj.experience_amount += amount
    experience_obj.save()


def update_streak_and_population(profile, module):
    today = timezone.now().date()
    status_obj, _ = ModuleStatus.objects.get_or_create(profile=profile, module_type=module)
    population_obj, _ = ModulePopulation.objects.get_or_create(profile=profile, module_type=module)
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
    population_obj.population += random.randint(1, 3)
    population_obj.population = max(population_obj.population, 0)
    status_obj.save()
    population_obj.save()