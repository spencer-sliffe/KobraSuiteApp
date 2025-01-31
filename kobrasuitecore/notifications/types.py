from django.db import models


class NotificationType(models.TextChoices):
    FINANCE = "FINANCE", "Finance"
    HOMELIFE = "HOMELIFE", "Homelife"
    WORK = "WORK", "Work"
    SCHOOL = "SCHOOL", "School"
    PROFILE = "PROFILE", "Profile"
    CALENDAR = "CALENDAR", "Calendar"


class ActionType(models.TextChoices):
    # For stocks or crypto
    INCREASE = "INCREASE", "Increase"
    DECREASE = "DECREASE", "Decrease"
    # For Due dates
    DUE = "DUE", "Due"
    COMING_UP = "COMING_UP", "Coming Up"
    IS_LATE = "IS_LATE", "Is Late"
    # General
    CHECK_ON = "CHECK_ON", "Check On"
    CHECK_OUT = "CHECK_OUT", "Check Out"
    DO_NOTHING = "DO_NOTHING", "Do Nothing"