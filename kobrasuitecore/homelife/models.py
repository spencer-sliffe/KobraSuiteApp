"""
------------------Prologue--------------------
File Name: homelife_models.py
Path: kobrasuitecore/homelife/models.py

Description:
Declares models for household management, including chores, pets, meal plans, shared
calendars, and more. Facilitates domestic organization for multiple occupant types.

Input:
None directly; data is stored and retrieved by other application components.

Output:
Database tables representing households, chores, events, groceries, medications, and related
home-life features.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import JSONField
from django.utils import timezone
from datetime import time, datetime
from homelife.types import HouseholdType, ChoreFrequency, MealType, DaysOfTheWeek


class Household(models.Model): # Creates household model
    name = models.CharField(max_length=100)
    household_type = models.CharField(max_length=20, choices=HouseholdType.choices, default=HouseholdType.FAMILY)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    class Meta:
        ordering = ['name']


class Pet(models.Model):
    CARE_FREQUENCY_CHOICES = [
        ("", "—"),  # ← NEW “blank” choice
        ("ONCE", "Once"),
        ("DAILY", "Daily"),
        ("WEEKLY", "Weekly"),
    ]

    household   = models.ForeignKey(Household, on_delete=models.CASCADE,
                                    related_name="pets")
    name        = models.CharField(max_length=100)
    pet_type    = models.CharField(max_length=50)

    #  —— instructions ——
    food_instructions        = models.TextField(blank=True)
    water_instructions       = models.TextField(blank=True)
    medication_instructions  = models.TextField(blank=True)

    #  —— schedules ——
    food_frequency = models.CharField(max_length=6, choices=CARE_FREQUENCY_CHOICES,
                                      default="", blank=True)
    food_times = models.JSONField(default=list, blank=True)  # unchanged

    water_frequency = models.CharField(max_length=6, choices=CARE_FREQUENCY_CHOICES,
                                       default="", blank=True)
    water_times = models.JSONField(default=list, blank=True)

    medication_frequency = models.CharField(max_length=6, choices=CARE_FREQUENCY_CHOICES,
                                            default="", blank=True)
    medication_times = models.JSONField(default=list, blank=True)

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    # helper – always return `time` objects
    def _as_times(self, lst):
        out = []
        for x in lst or []:
            if isinstance(x, time):
                out.append(x)
            else:  # string "HH:MM[:SS]"
                out.append(datetime.strptime(x, "%H:%M:%S").time())
        return out

    @property
    def food_time_objs(self):  # used by the calendar service
        return self._as_times(self.food_times)

    @property
    def water_time_objs(self):
        return self._as_times(self.water_times)

    @property
    def medication_time_objs(self):
        return self._as_times(self.medication_times)

    def clean(self):
        for freq, times, label in [
            (self.food_frequency, self.food_times, "food"),
            (self.water_frequency, self.water_times, "water"),
            (self.medication_frequency, self.medication_times, "medication"),
        ]:
            if not freq:  # block disabled
                continue
            if not times:
                raise ValidationError(f"{label}: at least one time required")
            if freq in ("ONCE", "WEEKLY") and len(times) > 1:
                raise ValidationError(
                    f"{label}: only one time allowed for {freq}"
                )

    class Meta:
        ordering = ["name"]


class SharedCalendarEvent(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name="calendar_events")
    title = models.CharField(max_length=100)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    description = models.TextField(blank=True)
    location = models.CharField(max_length=200, blank=True)
    source_content_type = models.ForeignKey(ContentType, null=True, blank=True, on_delete=models.SET_NULL)
    source_object_id = models.PositiveIntegerField(null=True, blank=True)
    source = GenericForeignKey("source_content_type", "source_object_id")
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ["start_datetime"]
        indexes = [
            models.Index(fields=["household", "start_datetime"]),
        ]

    def __str__(self):
        return f"{self.title} ({self.household.name})"


class Chore(models.Model): # creates chore model
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='chores')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    frequency = models.CharField(max_length=50, choices=ChoreFrequency.choices, default=ChoreFrequency.ONE_TIME)
    priority = models.IntegerField(default=1)
    available_from = models.DateTimeField(null=True, blank=True)
    available_until = models.DateTimeField(null=True, blank=True)
    assigned_to = models.ForeignKey(
        'hq.HomeLifeProfile',
        null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='assigned_chores'
    )

    child_assigned_to = models.ForeignKey(
        'homelife.ChildProfile',
        null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='assigned_child_chores'
    )

    def clean(self):
        """ensure exactly one assignee or none."""
        if self.assigned_to and self.child_assigned_to:
            raise ValidationError("Chore may be assigned to either an adult OR a child, not both.")

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.household.name}" # creates string representation of Chore model
# stores meta data for chores
    class Meta:
        ordering = ['-created_at']


class ChoreCompletion(models.Model): # model for completed chores
    chore = models.ForeignKey(Chore, on_delete=models.CASCADE, related_name='completions')
    homelife_profile = models.ForeignKey('hq.HomeLifeProfile', on_delete=models.CASCADE, related_name='chore_completions')
    completed_at = models.DateTimeField(default=timezone.now)
    is_on_time = models.BooleanField(default=True)
    points = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.homelife_profile.profile.user.username} completed {self.chore.title}" # string representation of completed chores
# stores meta data
    class Meta:
        ordering = ['-completed_at']


class MealPlan(models.Model): # creates meal plan Model
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='meal_plans')
    date = models.DateField()
    meal_type = models.CharField(max_length=50, choices=MealType.choices)
    recipe_name = models.CharField(max_length=100)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.recipe_name} on {self.date} ({self.household.name})"# string Representation
# stores creation date

    class Meta:
        ordering = ['-date']


class GroceryList(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='grocery_lists')
    name = models.CharField(max_length=100)
    run_datetime = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['run_datetime', 'created_at']


class GroceryItem(models.Model): # Creates Grocery Model
    grocery_list = models.ForeignKey(GroceryList, on_delete=models.CASCADE, related_name='grocery_items')
    name = models.CharField(max_length=100)
    quantity = models.CharField(max_length=50, blank=True)
    purchased = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.name} ({self.grocery_list.household.name})" # string representaion of Grocery ite
# stores meta data
    class Meta:
        ordering = ['purchased', 'name']


class Medication(models.Model): # creates Medication model
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='medications')
    name = models.CharField(max_length=100)
    dosage = models.CharField(max_length=50)
    frequency = models.CharField(max_length=50)
    next_dose = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.name} ({self.household.name})" # string representation of model
# stores meta data
    class Meta:
        ordering = ['name']


class MedicalAppointment(models.Model): # create appt model
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='medical_appointments')
    title = models.CharField(max_length=100)
    appointment_datetime = models.DateTimeField()
    doctor_name = models.CharField(max_length=100, blank=True)
    location = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})" # string representation of Medical appt
# stores appt  date

    class Meta:
        ordering = ['appointment_datetime']


class WorkoutRoutine(models.Model): # creates workout model
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='workout_routines')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    schedule = models.JSONField(default=list, blank=True)
    exercises = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})" # string representation of workout
# stores meta data for workout
    class Meta:
        ordering = ['title']


class ChildProfile(models.Model): # creates child profile model
    parent_profile = models.ForeignKey('hq.HomeLifeProfile', on_delete=models.CASCADE, related_name='child_profiles')
    name = models.CharField(max_length=100)
    date_of_birth = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name # string representation
# stores meta data
    class Meta:
        ordering = ['name']


class HouseholdInvite(models.Model):
    """
    One-time join code tied to a household.
    """
    household   = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='invites'
    )
    code        = models.CharField(max_length=20, unique=True)
    created_at  = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.code} → {self.household.name}"

    class Meta:
        ordering = ['-created_at']