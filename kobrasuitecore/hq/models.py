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
    profile = models.ForeignKey(
        UserProfile,
        on_delete=models.CASCADE,
        related_name='multipliers'
    )
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
    multiplier = models.FloatField(default=0.0)

    def __str__(self):
        return f"Multiplier for {self.profile.user.username}"