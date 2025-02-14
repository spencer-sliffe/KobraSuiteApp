from django.db import models


class HouseholdType(models.TextChoices):
    FAMILY = 'FAMILY', 'Family'
    ROOMMATES = 'ROOMMATES', 'Roommates'
    COUPLE = 'COUPLE', 'Couple'


class ChoreFrequency(models.TextChoices):
    ONE_TIME = 'ONE_TIME', 'One Time'
    DAILY = 'DAILY', 'Daily'
    WEEKLY = 'WEEKLY', 'Weekly'
    MONTHLY = 'MONTHLY', 'Monthly'
    CUSTOM = 'CUSTOM', 'Custom'


class MealType(models.TextChoices):
    BREAKFAST = 'BREAKFAST', 'Breakfast'
    LUNCH = 'LUNCH', 'Lunch'
    DINNER = 'DINNER', 'Dinner'
    SNACK = 'SNACK', 'Snack'