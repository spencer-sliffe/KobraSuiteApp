import math
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models
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

    def experience(self):
        return sum(e.experience_amount for e in self.module_experiences.all())

    def multiplier(self):
        total_population = sum(p.population for p in self.module_populations.all())
        streaks = self.module_statuses.values_list('current_streak', flat=True)
        top_streak = max(streaks) if streaks else 0
        rank_sum = 0
        for e in self.module_experiences.all():
            rank_sum += math.floor(math.log2(e.experience_amount + 1))
        v1 = max(1, math.log(total_population, 100)) if total_population > 0 else 1
        v2 = max(1, math.log2(top_streak)) if top_streak > 0 else 1
        return (v1 + v2) / 2 + rank_sum * 0.1

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
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='school_profile')
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='school_profile')
    university = models.ForeignKey(University, null=True, blank=True, on_delete=models.SET_NULL, related_name='school_profiles')
    courses = models.ManyToManyField(Course, related_name='school_profiles', blank=True)

    def __str__(self):
        return f"School Profile of {self.user.username}"


class WorkProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='work_profile')
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='work_profile')
    work_places = models.ManyToManyField(WorkPlace, related_name='work_profiles', blank=True)

    def __str__(self):
        return f"Work profile of {self.user.username}"


class FinanceProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='finance_profile')
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='finance_profile')

    def __str__(self):
        return f"Finance Profile of {self.user.username}"


class HomeLifeProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='homelife_profile')
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='homelife_profile')
    household = models.ForeignKey(Household, null=True, blank=True, on_delete=models.SET_NULL, related_name='homelife_profiles')

    def __str__(self):
        return f"HomeLife Profile of {self.user.username}"


class Multiplier(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='multipliers')
    multiplier_profile_content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, related_name='multiplier_profiles')
    multiplier_profile_object_id = models.PositiveIntegerField()
    multiplier_profile = GenericForeignKey('multiplier_profile_content_type', 'multiplier_profile_object_id')
    multiplier_obj_content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, related_name='multiplier_objects')
    multiplier_obj_object_id = models.PositiveIntegerField()
    multiplier_obj = GenericForeignKey('multiplier_obj_content_type', 'multiplier_obj_object_id')
    multiplier = models.FloatField(default=1.0)

    def __str__(self):
        return f"Multiplier for {self.profile.user.username}"


class Wallet(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='wallet')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    balance = models.IntegerField(default=0)

    def __str__(self):
        return f"Wallet for {self.profile.user.username}"


class ModuleExperience(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_experiences')
    module_type = models.CharField(max_length=20, choices=ModuleType.choices)
    experience_amount = models.FloatField(default=0.0)

    class Meta:
        unique_together = ('profile', 'module_type')

    def __str__(self):
        return f"{self.profile.user.username} - {self.module_type} Experience"


class ModuleStatus(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_statuses')
    module_type = models.CharField(max_length=20, choices=ModuleType.choices)
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
    module_type = models.CharField(max_length=20, choices=ModuleType.choices)
    population = models.IntegerField(default=0)

    class Meta:
        unique_together = ('profile', 'module_type')

    def __str__(self):
        return f"{self.profile.user.username} - {self.module_type} Population"


class ModuleTask(models.Model):
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_tasks')
    date = models.DateField()
    module = models.CharField(max_length=20, choices=ModuleType.choices)
    task_number = models.IntegerField()
    task_weight = models.FloatField(default=1.0)

    class Meta:
        unique_together = ('profile', 'date', 'module', 'task_number')

    def __str__(self):
        return f"{self.profile.user.username} {self.module} Task {self.task_number}"