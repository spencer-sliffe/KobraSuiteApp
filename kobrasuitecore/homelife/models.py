from django.db import models
from django.utils import timezone
from homelife.types import HouseholdType, ChoreFrequency, MealType


class Household(models.Model):
    name = models.CharField(max_length=100)
    household_type = models.CharField(max_length=20, choices=HouseholdType.choices, default=HouseholdType.FAMILY)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']


class Pet(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='pets')
    name = models.CharField(max_length=100)
    pet_type = models.CharField(max_length=50)
    special_instructions = models.TextField(blank=True)
    medications = models.TextField(blank=True)
    food_instructions = models.TextField(blank=True)
    water_instructions = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.pet_type})"

    class Meta:
        ordering = ['name']


class Chore(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='chores')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    frequency = models.CharField(max_length=50, choices=ChoreFrequency.choices, default=ChoreFrequency.ONE_TIME)
    priority = models.IntegerField(default=1)
    available_from = models.DateTimeField(null=True, blank=True)
    available_until = models.DateTimeField(null=True, blank=True)
    assigned_to = models.ForeignKey('hq.HomeLifeProfile', null=True, blank=True, on_delete=models.SET_NULL, related_name='assigned_chores')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.household.name}"

    class Meta:
        ordering = ['-created_at']


class ChoreCompletion(models.Model):
    chore = models.ForeignKey(Chore, on_delete=models.CASCADE, related_name='completions')
    profile = models.ForeignKey('hq.HomeLifeProfile', on_delete=models.CASCADE, related_name='chore_completions')
    completed_at = models.DateTimeField(default=timezone.now)
    is_on_time = models.BooleanField(default=True)
    points = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.profile.user.username} completed {self.chore.title}"

    class Meta:
        ordering = ['-completed_at']


class SharedCalendarEvent(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='calendar_events')
    title = models.CharField(max_length=100)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    description = models.TextField(blank=True)
    location = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})"

    class Meta:
        ordering = ['start_datetime']


class MealPlan(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='meal_plans')
    date = models.DateField()
    meal_type = models.CharField(max_length=50, choices=MealType.choices)
    recipe_name = models.CharField(max_length=100)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.recipe_name} on {self.date} ({self.household.name})"

    class Meta:
        ordering = ['-date']


class GroceryItem(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='grocery_items')
    name = models.CharField(max_length=100)
    quantity = models.CharField(max_length=50, blank=True)
    purchased = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.name} ({self.household.name})"

    class Meta:
        ordering = ['purchased', 'name']


class Medication(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='medications')
    name = models.CharField(max_length=100)
    dosage = models.CharField(max_length=50)
    frequency = models.CharField(max_length=50)
    next_dose = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.name} ({self.household.name})"

    class Meta:
        ordering = ['name']


class MedicalAppointment(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='medical_appointments')
    title = models.CharField(max_length=100)
    appointment_datetime = models.DateTimeField()
    doctor_name = models.CharField(max_length=100, blank=True)
    location = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})"

    class Meta:
        ordering = ['appointment_datetime']


class WorkoutRoutine(models.Model):
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='workout_routines')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    schedule = models.CharField(max_length=100)
    exercises = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})"

    class Meta:
        ordering = ['title']


class ChildProfile(models.Model):
    parent_profile = models.ForeignKey('hq.HomeLifeProfile', on_delete=models.CASCADE, related_name='child_profiles')
    name = models.CharField(max_length=100)
    date_of_birth = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']


class HouseholdInvite(models.Model):
    inviter = models.ForeignKey('hq.HomeLifeProfile', on_delete=models.CASCADE, related_name='sent_invites')
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='invites')
    code = models.CharField(max_length=20, unique=True)
    created_at = models.DateTimeField(default=timezone.now)
    redeemed_at = models.DateTimeField(null=True, blank=True)
    redeemed_by = models.ForeignKey('hq.HomeLifeProfile', null=True, blank=True, on_delete=models.SET_NULL, related_name='received_invites')

    def __str__(self):
        return f"Invite {self.code} by {self.inviter.user.username}"

    class Meta:
        ordering = ['-created_at']