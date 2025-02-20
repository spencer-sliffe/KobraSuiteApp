"""
------------------Prologue--------------------
File Name: types.py
Path: kobrasuitecore/customer/types.py

Description:
Enumerates possible MFA mechanisms (TOTP, SMS, PUSH) used within the application, ensuring
consistent references for multi-factor authentication.

Input:
None directly; used throughout the app to store and compare MFA type choices.

Output:
Enumerated constants for MFA types.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.db import models


class MFAType(models.TextChoices):
    TOTP = "TOTP", "Time-Based OTP"
    SMS = "SMS", "SMS"
    PUSH = "PUSH", "Push Notification"
