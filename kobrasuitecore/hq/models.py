"""
------------------Prologue--------------------
File Name: models.py
Path: kobrasuitecore/hq/models.py

Date Created:
2025-02-21

Date Updated:
2025-03-16

Description:
(TEMP) Contains user profile models and module-specific data structures for tracking experience, status, and progress across different modules like school, work, and home life.

Input:
(TEMP) User data and module interaction records from related applications (school, work, homelife).

Output:
(TEMP) Structured data representing user profiles, module progress metrics, and calendar events across integrated systems.

Collaborators: SPENCER SLIFFE, JAKE BERNARD, CHATGPT from "OPEN"AI
---------------------------------------------
"""

import math

from django.db import models
from django.utils import timezone

from customer.models import User
from homelife.models import Household
from school.models import Course, University
from work.models import WorkPlace
from .types import ModuleType


# (TEMP) Main user profile model extending core User functionality
class UserProfile(models.Model):
    # (TEMP) One-to-one link to core User model
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    # (TEMP) Date of birth field with optional values
    date_of_birth = models.DateField(null=True, blank=True)
    # (TEMP) Text-based address information
    address = models.TextField(null=True, blank=True)
    # (TEMP) Image field for profile pictures
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)
    # (TEMP) JSON-stored user preferences
    preferences = models.JSONField(null=True, blank=True)

    # (TEMP) Calculate total experience across all modules
    def experience(self):
        # (TEMP) Sum experience amounts from all module experiences
        return sum(e.experience_amount for e in self.module_experiences.all())

    # (TEMP) Calculate multiplier based on population, streaks, and experience ranks
    def multiplier(self):
        # (TEMP) Calculate total population across all module populations
        total_population = sum(p.population for p in self.module_populations.all())
        # (TEMP) Extract current streak values from module statuses
        streaks = self.module_statuses.values_list('current_streak', flat=True)
        # (TEMP) Determine top streak value
        top_streak = max(streaks) if streaks else 0
        # (TEMP) Initialize rank sum accumulator
        rank_sum = 0
        # (TEMP) Iterate through module experiences to calculate rank contributions
        for e in self.module_experiences.all():
            # (TEMP) Add log2-based rank contribution for each experience
            rank_sum += math.floor(math.log2(e.experience_amount + 1))
        # (TEMP) Calculate v1 component with logarithmic scaling
        v1 = max(1, math.log(total_population, 10)) if total_population > 0 else 1
        # (TEMP) Calculate v2 component with logarithmic scaling
        v2 = max(1, math.log2(top_streak)) if top_streak > 0 else 1
        # (TEMP) Combine components into final multiplier value
        return (v1 + v2) / 2 + rank_sum

    # (TEMP) Compile module status data into dictionary format
    def get_status(self):
        # (TEMP) Return dictionary mapping module types to status details
        return {
            s.module_type: {
                'streak_start': s.streak_start,
                'current_streak': s.current_streak,
                'max_streak': s.max_streak,
                'building_level': s.building_level
            }
            for s in self.module_statuses.all()
        }

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"Profile of {self.user.username}"


# (TEMP) School-specific profile linking to university and courses
class SchoolProfile(models.Model):
    # (TEMP) One-to-one link to core User model
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='school_profile')
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='school_profile')
    # (TEMP) Foreign key to university model
    university = models.ForeignKey(University, null=True, blank=True, on_delete=models.SET_NULL, related_name='school_profiles')
    # (TEMP) Many-to-many relationship with courses
    courses = models.ManyToManyField(Course, related_name='school_profiles', blank=True)

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"School Profile of {self.user.username}"


# (TEMP) Work-specific profile linking to workplaces
class WorkProfile(models.Model):
    # (TEMP) One-to-one link to core User model
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='work_profile')
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='work_profile')
    # (TEMP) Many-to-many relationship with workplaces
    work_places = models.ManyToManyField(WorkPlace, related_name='work_profiles', blank=True)

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"Work profile of {self.user.username}"


# (TEMP) Financial tracking profile
class FinanceProfile(models.Model):
    # (TEMP) One-to-one link to core User model
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='finance_profile')
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='finance_profile')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"Finance Profile of {self.user.username}"


# (TEMP) Home life profile linking to household data
class HomeLifeProfile(models.Model):
    # (TEMP) One-to-one link to core User model
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='homelife_profile')
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='homelife_profile')
    # (TEMP) Foreign key to household model
    household = models.ForeignKey(Household, null=True, blank=True, on_delete=models.SET_NULL, related_name='homelife_profiles')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"HomeLife Profile of {self.user.username}"


# (TEMP) User wallet model for financial balance tracking
class Wallet(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='wallet')
    # (TEMP) Creation timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    # (TEMP) Last update timestamp
    updated_at = models.DateTimeField(auto_now=True)
    # (TEMP) Current financial balance
    balance = models.IntegerField(default=0)

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"Wallet for {self.profile.user.username}"


# (TEMP) Tracks experience points per module type
class ModuleExperience(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_experiences')
    # (TEMP) Module type identifier with choices from ModuleType
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    # (TEMP) Accumulated experience points for the module
    experience_amount = models.FloatField(default=0.0)

    class Meta:
        # (TEMP) Enforce unique profile-module pairs
        unique_together = ('profile', 'module_type')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"{self.profile.user.username} - {self.module_type} Experience"


# (TEMP) Tracks module-specific streaks and building progress
class ModuleStatus(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_statuses')
    # (TEMP) Module type identifier with choices from ModuleType
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    # (TEMP) Date when current streak began
    streak_start = models.DateField(null=True, blank=True)
    # (TEMP) Current active streak count
    current_streak = models.IntegerField(default=0)
    # (TEMP) Highest achieved streak count
    max_streak = models.IntegerField(default=0)
    # (TEMP) Current building level in the module
    building_level = models.IntegerField(default=0)

    class Meta:
        # (TEMP) Enforce unique profile-module pairs
        unique_together = ('profile', 'module_type')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"{self.profile.user.username} - {self.module_type} Status"


# (TEMP) Tracks population metrics per module
class ModulePopulation(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='module_populations')
    # (TEMP) Module type identifier with choices from ModuleType
    module_type = models.CharField(max_length=1, choices=ModuleType.choices)
    # (TEMP) Current population count for the module
    population = models.IntegerField(default=0)

    class Meta:
        # (TEMP) Enforce unique profile-module pairs
        unique_together = ('profile', 'module_type')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"{self.profile.user.username} - {self.module_type} Population"


# (TEMP) Calendar events linked to user profiles and modules
class CalendarEvent(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(
        'hq.UserProfile',
        on_delete=models.CASCADE,
        related_name='calendar_events'
    )
    # (TEMP) Module type identifier with choices from ModuleType
    module_type = models.CharField(
        max_length=20,
        choices=ModuleType.choices,
        blank=True,
        null=True
    )
    # (TEMP) Event title
    title = models.CharField(max_length=200)
    # (TEMP) Event description text
    description = models.TextField(blank=True)
    # (TEMP) Event start time
    start_datetime = models.DateTimeField()
    # (TEMP) Event end time
    end_datetime = models.DateTimeField()
    # (TEMP) Boolean indicating all-day event
    is_all_day = models.BooleanField(default=False)
    # (TEMP) Creation timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    # (TEMP) Last update timestamp
    updated_at = models.DateTimeField(auto_now=True)

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"CalendarEvent {self.title} for {self.profile.user.username}"


# (TEMP) Tracks task category progress with renewal timestamps
class TaskCategoryProgress(models.Model):
    # (TEMP) Link to main user profile
    profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='task_category_progresses')
    # (TEMP) Module type identifier with choices from ModuleType
    module = models.CharField(max_length=1, choices=ModuleType.choices)
    # (TEMP) Unique category identifier
    category_id = models.PositiveIntegerField()
    # (TEMP) Number of completed tasks in category
    completion_count = models.PositiveIntegerField(default=0)
    # (TEMP) Timestamp of last progress renewal
    last_renewed_at = models.DateTimeField(default=timezone.now)

    class Meta:
        # (TEMP) Enforce unique profile-module-category tuples
        unique_together = ('profile', 'module', 'category_id')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation
        return f"{self.profile.user.username} {self.module} Cat {self.category_id} Progress"


# (TEMP) Tracks individual task slots and completion status
class TaskCategorySlots(models.Model):
    # (TEMP) Link to task category progress record
    progress = models.ForeignKey(TaskCategoryProgress, on_delete=models.CASCADE, related_name='slots')
    # (TEMP) Binary representation of available task slots
    slots = models.BigIntegerField(default=0)
    # (TEMP) Binary representation of completed task slots
    completed = models.BigIntegerField(default=0)

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation with binary slot status
        return (
            f"{self.progress.profile.user.username} {self.progress.module} "
            f"Cat {self.progress.category_id} Slots {self.slots:064b} "
            f"Completed {self.completed:064b}"
        )


# (TEMP) Stores performance metrics for individual task slots
class TaskPerformanceBounds(models.Model):
    # (TEMP) Link to task category progress record
    progress = models.ForeignKey(TaskCategoryProgress, on_delete=models.CASCADE, related_name='performance_bounds')
    # (TEMP) Index of the specific task slot
    slot_index = models.IntegerField(default=-1)
    # (TEMP) JSON-stored performance data for the slot
    data = models.JSONField(default=dict, blank=True)

    class Meta:
        # (TEMP) Enforce unique progress-slot pairs
        unique_together = ('progress', 'slot_index')

    # (TEMP) String representation for debugging
    def __str__(self):
        # (TEMP) Format username-based string representation with slot details
        return (
            f"{self.progress.profile.user.username} {self.progress.module} "
            f"Cat {self.progress.category_id} Slot {self.slot_index} Bounds"
        )
