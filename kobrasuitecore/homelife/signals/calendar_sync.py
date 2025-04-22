from django.db.models.signals import post_delete, post_save
from django.dispatch import receiver
from homelife.models import (
    Chore,
    WorkoutRoutine,
    Medication,
    MedicalAppointment,
    GroceryList,
    Pet,
    MealPlan,
)
from homelife.services.calendar_event_service import CalendarEventService


@receiver(post_save, sender=Chore)
@receiver(post_save, sender=WorkoutRoutine)
@receiver(post_save, sender=Medication)
@receiver(post_save, sender=MedicalAppointment)
@receiver(post_save, sender=GroceryList)
@receiver(post_save, sender=Pet)
@receiver(post_save, sender=MealPlan)
def create_or_update_calendar_event(sender, instance, **kwargs):
    CalendarEventService.sync(instance)


@receiver(post_delete, sender=Chore)
@receiver(post_delete, sender=WorkoutRoutine)
@receiver(post_delete, sender=Medication)
@receiver(post_delete, sender=MedicalAppointment)
@receiver(post_delete, sender=GroceryList)
@receiver(post_delete, sender=Pet)
@receiver(post_delete, sender=MealPlan)
def remove_calendar_event(sender, instance, **kwargs):
    CalendarEventService.delete(instance)