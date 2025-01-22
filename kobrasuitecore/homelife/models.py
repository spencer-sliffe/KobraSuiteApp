from django.db import models
from django.conf import settings
from homelife.types import ChoreFrequency, MealType
from django.utils import timezone


class Household(models.Model):
    """
    Represents a household (family unit) with multiple members.
    """
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    members = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='households',
        blank=True
    )

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']


class Chore(models.Model):
    """
    Individual chore or task in a household (laundry, dishes, etc.).
    """
    household = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='chores'
    )
    title = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    frequency = models.CharField(
        max_length=50,
        choices=ChoreFrequency.choices,
        default=ChoreFrequency.ONE_TIME
    )
    priority = models.IntegerField(default=1)
    due_date = models.DateField(null=True, blank=True)
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.household.name}"

    class Meta:
        ordering = ['-created_at']


class SharedCalendarEvent(models.Model):
    """
    Events on a shared family calendar (doctor appointments, birthdays).
    """
    household = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='calendar_events'
    )
    title = models.CharField(max_length=100)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    description = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=200, null=True, blank=True)

    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} ({self.household.name})"

    class Meta:
        ordering = ['start_datetime']


class MealPlan(models.Model):
    """
    Planned meals for the household (daily/weekly).
    """
    household = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='meal_plans'
    )
    date = models.DateField()
    meal_type = models.CharField(
        max_length=50,
        choices=MealType.choices
    )
    recipe_name = models.CharField(max_length=100)
    notes = models.TextField(null=True, blank=True)

    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.recipe_name} on {self.date} ({self.household.name})"

    class Meta:
        ordering = ['-date']


class GroceryItem(models.Model):
    """
    Items needed for the household's grocery list.
    """
    household = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='grocery_items'
    )
    name = models.CharField(max_length=100)
    quantity = models.CharField(max_length=50, null=True, blank=True)
    purchased = models.BooleanField(default=False)

    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.name} ({self.household.name})"

    class Meta:
        ordering = ['purchased', 'name']