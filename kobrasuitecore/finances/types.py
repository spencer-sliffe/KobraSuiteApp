# /finances/types.py

from django.db import models


class CategoryType(models.TextChoices):
    NECESSARY = 'NECESSARY', 'Necessary Expenses'
    UNNECESSARY = 'UNNECESSARY', 'Unnecessary Expenses'
    INVESTING = 'INVESTING', 'Investing'