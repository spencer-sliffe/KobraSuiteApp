from django.db import models

class NotificationType(models.TextChoices):
    FINANCE = "FINANCE", "Finance"
    HOMELIFE = "HOMELIFE", "Homelife"
    WORK = "WORK", "Work"
    SCHOOL = "SCHOOL", "School"
    OTHER = "OTHER", "Other"
