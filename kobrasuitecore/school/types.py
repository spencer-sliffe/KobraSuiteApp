"""
------------------Prologue--------------------
File Name: types.py
Path: kobrasuitecore/school/types.py

Description:
Defines enumerated types and regular expression patterns for the school module.
Includes discussion scope choices, semester format validation, course code regex, and semester choices.

Input:
None directly; used internally for model field validations and choice constraints.

Output:
Constant values and regex patterns employed throughout the school application.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/types.py
import re
from django.db import models


class DiscussionScope(models.TextChoices):
    UNIVERSITY = "UNIVERSITY", "University"
    COURSE = "COURSE", "Course"
    ASSIGNMENT = "ASSIGNMENT", "Assignment"


SEMESTER_REGEX = re.compile(r'^(SUMMER|SPRING|FALL|WINTER) \d{4}$')
COURSE_CODE_REGEX = re.compile(r'^[A-Za-z]{2,4}\d{3,4}$')

SEMESTER_CHOICES = [
    ('SUMMER', 'Summer'),
    ('SPRING', 'Spring'),
    ('FALL', 'Fall'),
    ('WINTER', 'Winter'),
]

VALID_SCOPE_TYPES = [DiscussionScope.UNIVERSITY, DiscussionScope.COURSE, DiscussionScope.ASSIGNMENT]