"""
------------------Prologue--------------------
File Name: models.py
Path: kobrasuitecore/customer/models.py

Description:
Contains custom extensions to the default User model and related classes such as Role, MFAConfig,
and SecureDocument. Facilitates role-based permissions, multi-factor authentication, and secure
file storage.

Input:
None directly; populated and queried by application logic.

Output:
Database structures representing users, roles, MFA configurations, and stored documents.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.db import models
from django.contrib.auth.models import AbstractUser, Permission
from django.core.validators import RegexValidator
from django.utils import timezone

from .types import MFAType


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