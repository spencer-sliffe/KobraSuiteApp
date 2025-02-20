"""
------------------Prologue--------------------
File Name: types.py
Path: kobrasuitecore/work/types.py

Description:
Defines enumerated text choices for categorizing workplace fields.
Provides standardized options such as TECHNOLOGY, RETAIL, AUTOMOBILE, FINANCE, HEALTHCARE, EDUCATION, REAL_ESTATE, MEDIA, and OTHER.
Ensures consistent categorization of workplace data across the application.

Input:
None directly; used internally for field validation in the WorkPlace model.

Output:
Constant string values representing valid workplace fields.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
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

