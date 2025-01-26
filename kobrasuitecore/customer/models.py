from django.db import models
from django.contrib.auth.models import AbstractUser, Permission
from django.core.validators import RegexValidator
from django.utils import timezone

from work.models import WorkPlace
from .types import MFAType
from school.models import University, Course


class User(AbstractUser):
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Phone number must be in the format: '+999999999'. Up to 15 digits allowed."
    )
    phone_number = models.CharField(
        validators=[phone_regex],
        max_length=17,
        blank=True,
        null=True
    )
    is_email_verified = models.BooleanField(default=False)
    is_phone_verified = models.BooleanField(default=False)

    def has_role(self, role_name: str) -> bool:
        return self.roles.filter(name=role_name).exists()

    def __str__(self):
        return self.username


class Role(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(null=True, blank=True)
    permissions = models.ManyToManyField(
        Permission,
        blank=True,
        related_name='roles'
    )
    users = models.ManyToManyField(
        'User',
        related_name='roles',
        blank=True
    )

    def __str__(self):
        return self.name


class MFAConfig(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    mfa_enabled = models.BooleanField(default=False)
    mfa_type = models.CharField(
        max_length=50,
        choices=MFAType.choices,
        null=True,
        blank=True
    )
    secret_key = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return f"MFAConfig for {self.user.username}"


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
    work_places = models.ManyToManyField(WorkPlace, related_name='work_profiles', blank=True)

    def __str__(self):
        return f"Work profile of {self.user.username}"


class SecureDocument(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='documents'
    )
    title = models.CharField(max_length=100)
    file = models.FileField(upload_to='secure_documents/')
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.title} - {self.user.username}"