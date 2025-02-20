from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import ModuleTask
from .tasks import apply_task_rewards

@receiver(post_save, sender=ModuleTask)
def handle_module_task_creation(sender, instance, created, **kwargs):
    if created:
        apply_task_rewards(instance)