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
from finances.models import StockPortfolio

User = get_user_model()


@receiver(post_save, sender=User)
def create_profiles(sender, instance, created, **kwargs):
    if created:
        user_profile = UserProfile.objects.create(user=instance)
        SchoolProfile.objects.create(profile=user_profile)
        WorkProfile.objects.create(profile=user_profile)
        financeprofile=FinanceProfile.objects.create(profile=user_profile)
        StockPortfolio.objects.create(finance_profile=financeprofile)
        HomeLifeProfile.objects.create(profile=user_profile)


@receiver(post_save, sender=User)
def save_profiles(sender, instance, **kwargs):
    if hasattr(instance, 'profile'):
        instance.profile.save()
        if hasattr(instance.profile, 'school_profile'):
            instance.profile.school_profile.save()
        if hasattr(instance.profile, 'work_profile'):
            instance.profile.work_profile.save()
        if hasattr(instance.profile, 'finance_profile'):
            instance.profile.finance_profile.save()
            if hasattr(instance.profile.finance_profile, 'stockportfolio'):
                    instance.profile.finance_profile.stockportfolio.save()
        if hasattr(instance.profile, 'homelife_profile'):
            instance.profile.homelife_profile.save()