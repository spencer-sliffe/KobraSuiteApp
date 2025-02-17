"""
------------------Prologue--------------------
File Name: signals.py
Path: kobrasuitecore/customer/signals.py

Description:
Automatically creates user-related profiles (general, school, work, finance, homelife) after
a User instance is saved, initializing these profiles for newly registered users.

Input:
User instances monitored through Django signals.

Output:
Profile objects for each user, updated or newly created.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# customer/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from hq.models import UserProfile, SchoolProfile, WorkProfile, FinanceProfile, HomeLifeProfile

User = get_user_model()


@receiver(post_save, sender=User)
def create_profiles(sender, instance, created, **kwargs):
    p1=None
    if created:
        if not UserProfile.objects.filter(user=instance).exists():
            p1=UserProfile.objects.create(user=instance)
        if not SchoolProfile.objects.filter(user=instance).exists():
            SchoolProfile.objects.create(user=instance, profile=p1)
        if not WorkProfile.objects.filter(user=instance).exists():
            WorkProfile.objects.create(user=instance, profile=p1)
        if not FinanceProfile.objects.filter(user=instance).exists():
            FinanceProfile.objects.create(user=instance, profile=p1)
        if not HomeLifeProfile.objects.filter(user=instance).exists():
            HomeLifeProfile.objects.create(user=instance, profile=p1)


@receiver(post_save, sender=User)
def save_profiles(sender, instance, **kwargs):
    if hasattr(instance, 'profile'):
        instance.profile.save()
    if hasattr(instance, 'school_profile'):
        instance.school_profile.save()
    if hasattr(instance, 'work_profile'):
        instance.work_profile.save()
    if hasattr(instance, 'finance_profile'):
        instance.finance_profile.save()
    if hasattr(instance, 'homelife_profile'):
        instance.homelife_profile.save()
