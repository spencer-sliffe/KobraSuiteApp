from django.dispatch import receiver
from django.db.models.signals import post_save
from homelife.models import ChoreCompletion
from hq.models import ModuleExperience, Wallet


@receiver(post_save, sender=ChoreCompletion)
def update_experience_on_chore_completion(sender, instance, created, **kwargs):
    if created:
        user_profile = instance.profile.profile
        experience, _ = ModuleExperience.objects.get_or_create(profile=user_profile, module_type='HOMELIFE')
        experience.experience_amount += instance.points
        experience.save()


@receiver(post_save, sender=ChoreCompletion)
def update_wallet_on_chore_completion(sender, instance, created, **kwargs):
    if created:
        user_profile = instance.profile.profile
        wallet, _ = Wallet.objects.get_or_create(profile=user_profile)
        wallet.balance += instance.points
        wallet.save()