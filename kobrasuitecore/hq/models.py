from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models

from customer.models import User
from homelife.models import Household
from school.models import Course, University
from work.models import WorkPlace


class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile'
    )
    date_of_birth = models.DateField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    profile_picture = models.ImageField(
        upload_to='profile_pics/',
        null=True,
        blank=True
    )
    preferences = models.JSONField(null=True, blank=True)

    def experience(self):
        """ return a sum of all of a user's ModuleExperience """

    def multiplier(self):
        """ may be used to return a user's multiplier """

    def get_status(self):
        """ returns max streak for each module as a dictionary from each module's ModuleStreak """

    def __str__(self):
        return f"Profile of {self.user.username}"


class SchoolProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='school_profile'
    )
    profile = models.ForeignKey(
        UserProfile,
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='school_profile'
    )
    university = models.ForeignKey(
        University,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='school_profiles'
    )
    courses = models.ManyToManyField(
        Course,
        related_name='school_profiles',
        blank=True
    )

    def __str__(self):
        return f"School Profile of {self.user.username}"


class WorkProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='work_profile')
    profile = models.ForeignKey(
        UserProfile,
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='work_profile'
    )
    work_places = models.ManyToManyField(WorkPlace, related_name='work_profiles', blank=True)

    def __str__(self):
        return f"Work profile of {self.user.username}"


class FinanceProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='finance_profile')
    profile = models.ForeignKey(
        UserProfile,
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='finance_profile'
    )

    def __str__(self):
        return f"Finance Profile of {self.user.username}"


class HomeLifeProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='homelife_profile'
    )
    profile = models.ForeignKey(
        UserProfile,
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='homelife_profile'
    )
    household = models.ForeignKey(
        Household,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='homelife_profiles',
    )

    def str(self):
        return f"HomeLife Profile of {self.user.username}"


class Multiplier(models.Model):
    # User profile
    profile = models.ForeignKey(
        UserProfile,
        on_delete=models.CASCADE,
        related_name='multipliers'
    )

    # Multiplier Context
    multiplier_profile_content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        related_name='multiplier_profiles'
    )
    multiplier_profile_object_id = models.PositiveIntegerField()
    multiplier_profile = GenericForeignKey(
        'multiplier_profile_content_type',
        'multiplier_profile_object_id'
    )
    multiplier_obj_content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        related_name='multiplier_objects'
    )
    multiplier_obj_object_id = models.PositiveIntegerField()
    multiplier_obj = GenericForeignKey(
        'multiplier_obj_content_type',
        'multiplier_obj_object_id'
    )
    # Multiplier Value
    multiplier = models.FloatField(default=1.0)

    def __str__(self):
        return f"Multiplier for {self.profile.user.username}"

class Wallet(models.Model):
    profile = models.ForeignKey(
        UserProfile,
        on_delete=models.CASCADE,
        related_name='wallet'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    balance = models.IntegerField(default=0)

class ModuleExperience(models.Model):
    """
    Each ModuleExperience object should be related to a module profile and a user profile.
    This is a one-to-one relationship. There is an ModuleExperience object per module per user profile.
    There are 4 ModuleExperience objects per user profile. These profiles are School, Finance, HomeLife, and Work.

    There is a field for the amount of experience, which should be a double.
    """

class ModuleStatus(models.Model):
    """
    Per user, per module, ModuleStatus has a one-to-one relationship.
    Each user, for each module, has a ModuleStatus object.
    The module status tracks the login streak of the user per module and also keeps track of their longest login streak.
    The start of the latest streak is also kept as a date.
    """
    streak_start = models.DateField(null=True, blank=True)
    current_streak = models.IntegerField(default=0)
    max_streak = models.IntegerField(default=0)

class ModulePopulation(models.Model):
    """
    Per user, per module, ModulePopulation has a one-to-one relationship.
    Each user, for each module, has a ModulePopulation object.
    The ModulePopulation tracks a population field only, which is an integer.
    The population field is
    """
    population = models.IntegerField(default=0)


