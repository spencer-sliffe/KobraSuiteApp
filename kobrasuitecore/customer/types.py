from django.db import models

class MFAType(models.TextChoices):
    TOTP = "TOTP", "Time-Based OTP"
    SMS = "SMS", "SMS"
    PUSH = "PUSH", "Push Notification"
