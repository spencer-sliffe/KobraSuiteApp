from django.db import models


class WorkPlaceField(models.TextChoices):
    TECHNOLOGY = "TECHNOLOGY", "Technology"
    RETAIL = "RETAIL", "Retail"
    AUTOMOBILE = "AUTOMOBILE", "Automobile"
    FINANCE = "FINANCE", "Finance"
    HEALTHCARE = "HEALTHCARE", "Healthcare"
    EDUCATION = "EDUCATION", "Education"
    REAL_ESTATE = "REAL_ESTATE", "Real Estate"
    MEDIA = "MEDIA", "Media"
    OTHER = "OTHER", "Other"


# class WorkTaskStatus(models.TextChoices):
#     TODO = "TODO", "To Do"
#     IN_PROGRESS = "IN_PROGRESS", "In Progress"
#     DONE = "DONE", "Done"
#

