import math

from django.db import models
from django.utils import timezone

from customer.models import User
from homelife.models import Household
from school.models import Course, University
from work.models import WorkPlace
from .types import ModuleType


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    date_of_birth = models.DateField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)
    preferences = models.JSONField(null=True, blank=True)

    # TODO: (JAKE, USER PROFILE MODEL) Fix these broken garbage functions
    def experience(self):
        return sum(e.experience_amount for e in self.module_experiences.all())

    def multiplier(self):
        total_population = sum(p.population for p in self.module_populations.all())
        streaks = self.module_statuses.values_list('current_streak', flat=True)
        top_streak = max(streaks) if streaks else 0
        rank_sum = 0
        for e in self.module_experiences.all():
            rank_sum += math.floor(math.log2(e.experience_amount + 1))
        v1 = max(1, math.log(total_population, 10)) if total_population > 0 else 1
        v2 = max(1, math.log2(top_streak)) if top_streak > 0 else 1
        return (v1 + v2) / 2 + rank_sum

    def get_status(self):
        return {
            s.module_type: {
                'streak_start': s.streak_start,
                'current_streak': s.current_streak,
                'max_streak': s.max_streak,
                'building_level': s.building_level
            }
            for s in self.module_statuses.all()
        }

    def __str__(self):
        return f"Profile of {self.user.username}"


class SchoolProfile(models.Model):
    profile = models.OneToOneField(
        UserProfile,
        on_delete=models.CASCADE,
        related_name='school_profile'
    )
    university = models.ForeignKey(
        University,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='school_profiles'
    )
    courses = models.ManyToManyField(
        Course,
        related_name='school_profiles',
        blank=True
    )

    def __str__(self):
        return f"School Profile of {self.profile.user.username}"


class WorkProfile(models.Model):
    profile = models.OneToOneField(UserProfile, on_delete=models.CASCADE, related_name='work_profile')
    work_places = models.ManyToManyField(WorkPlace, related_name='work_profiles', blank=True)

    def __str__(self):
        return f"Work profile of {self.profile.user.username}"

class FinanceProfile(models.Model):
    profile = models.OneToOneField(UserProfile, on_delete=models.CASCADE, related_name='finance_profile')

    def __str__(self):
        return f"Finance Profile of {self.profile.user.username}"


class HomeLifeProfile(models.Model):
    profile = models.OneToOneField(UserProfile, on_delete=models.CASCADE, related_name='homelife_profile')
    household = models.ForeignKey(Household, null=True, blank=True, on_delete=models.SET_NULL,
                                  related_name='homelife_profiles')

    def __str__(self):
        return f"HomeLife profile of {self.profile.user.username}"

class Wallet(models.Model):
    profile = models.OneToOneField(UserProfile, on_delete=models.CASCADE, related_name='wallet')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    balance = models.IntegerField(default=0)

    def __str__(self):
        return f"Wallet for {self.profile.user.username}"


class ModuleExperience(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_experiences')
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    experience_amount = models.FloatField(default=0.0)

    class Meta:
        unique_together = ('profile', 'module_type')

    def __str__(self):
        return f"{self.profile.user.username} - {self.module_type} Experience"


class ModuleStatus(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_statuses')
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    streak_start = models.DateField(null=True, blank=True)
    current_streak = models.IntegerField(default=0)
    max_streak = models.IntegerField(default=0)
    building_level = models.IntegerField(default=0)

    class Meta:
        unique_together = ('profile', 'module_type')

    def __str__(self):
        return f"{self.profile.user.username} - {self.module_type} Status"


class ModulePopulation(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_populations')
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    population = models.IntegerField(default=0)

    class Meta:
        unique_together = ('profile', 'module_type')

    def __str__(self):
        return f"{self.profile.user.username} - {self.module_type} Population"


class CalendarEvent(models.Model):
    profile = models.ForeignKey(
        'hq.UserProfile',
        on_delete=models.CASCADE,
        related_name='calendar_events'
    )
    module_type = models.CharField(
        max_length=20,
        choices=ModuleType.choices,
        blank=True,
        null=True
    )
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    is_all_day = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"CalendarEvent {self.title} for {self.profile.user.username}"

# TODO: (JAKE) Update the name of this in the docs or here
#   and also update name of completion count/category id if those are inconsistent
class TaskCategoryProgress(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='task_category_progresses')
    module = models.CharField(max_length=1, choices=ModuleType.choices)
    category_id = models.PositiveIntegerField()
    completion_count = models.PositiveIntegerField(default=0)
    last_renewed_at = models.DateTimeField(default=timezone.now)

    class Meta:
        unique_together = ('profile', 'module', 'category_id')

    def __str__(self):
        return f"{self.profile.user.username} {self.module} Cat {self.category_id} Progress"


# TODO: (JAKE) Update name of this and its fields in docs
class TaskCategorySlots(models.Model):
    progress = models.ForeignKey(TaskCategoryProgress, on_delete=models.CASCADE, related_name='slots')
    slots = models.BigIntegerField(default=0)
    completed = models.BigIntegerField(default=0)

    def __str__(self):
        return (
            f"{self.progress.profile.user.username} {self.progress.module} "
            f"Cat {self.progress.category_id} Slots {self.slots:064b} "
            f"Completed {self.completed:064b}"
        )


class TaskPerformanceBounds(models.Model):
    progress = models.ForeignKey(TaskCategoryProgress, on_delete=models.CASCADE, related_name='performance_bounds')
    slot_index = models.IntegerField(default=-1)
    data = models.JSONField(default=dict, blank=True)

    class Meta:
        unique_together = ('progress', 'slot_index')

    def __str__(self):
        return (
            f"{self.progress.profile.user.username} {self.progress.module} "
            f"Cat {self.progress.category_id} Slot {self.slot_index} Bounds"
        )