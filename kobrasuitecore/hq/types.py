from django.db import models


class ModuleType(models.TextChoices):
    SCHOOL = 'S', 'School'
    WORK = 'W', 'Work'
    HOMELIFE = 'H', 'HomeLife'
    FINANCE = 'H', 'Finance'