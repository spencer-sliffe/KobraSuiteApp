"""
------------------Prologue--------------------
File Name: homelife_types.py
Path: kobrasuitecore/homelife/types.py

Description:
Defines enumerated text choices for household types, chore frequencies, and meal types.
These choices help maintain consistent references and validations across the homelife app.

Input:
None directly; used for referencing enumerated options within the models.

Output:
Constant string values representing valid types for household structures and chores.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
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


class DaysOfTheWeek(models.TextChoices):
    MONDAY = 'MONDAY', 'Monday'
    TUESDAY = 'TUESDAY', 'Tuesday'
    WEDNESDAY = 'WEDNESDAY', 'Wednesday'
    THURSDAY = 'THURSDAY', 'Thursday'
    FRIDAY = 'FRIDAY', 'Friday'
    SATURDAY = 'SATURDAY', 'Saturday'
    SUNDAY = 'SUNDAY', 'Sunday'
