from django.db import models


class ModuleType(models.TextChoices):
    SCHOOL = "SCHOOL", "School"
    WORK = "WORK", "Work"
    HOMELIFE = "HOMELIFE", "HomeLife"
    FINANCE = "FINANCE", "Finance"