# customer/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from .models import UserProfile, SchoolProfile, WorkProfile, FinanceProfile

User = get_user_model()


@receiver(post_save, sender=User)
def create_profiles(sender, instance, created, **kwargs):
    if created:
        if not SchoolProfile.objects.filter(user=instance).exists():
            SchoolProfile.objects.create(user=instance)
        if not UserProfile.objects.filter(user=instance).exists():
            UserProfile.objects.create(user=instance)
        if not WorkProfile.objects.filter(user=instance).exists():
            WorkProfile.objects.create(user=instance)
        if not FinanceProfile.objects.filter(user=instance).exists():
            FinanceProfile.objects.create(user=instance)


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