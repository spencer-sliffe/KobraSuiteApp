from datetime import datetime, timedelta, time

from dateutil.relativedelta import relativedelta
from django.contrib.contenttypes.models import ContentType
from django.utils import timezone

from homelife.models import (
    Chore,
    GroceryList,
    MealPlan,
    MedicalAppointment,
    Medication,
    Pet,
    SharedCalendarEvent,
    WorkoutRoutine,
)
from homelife.types import ChoreFrequency, DaysOfTheWeek, MealType


MEAL_TIMES = {
    MealType.BREAKFAST: time(8, 0),
    MealType.LUNCH: time(12, 0),
    MealType.SNACK: time(15, 0),
    MealType.DINNER: time(18, 0),
}


class CalendarEventService:
    @staticmethod
    def sync(instance):
        CalendarEventService.delete(instance)

        if isinstance(instance, Chore):
            CalendarEventService._sync_chore(instance)
        elif isinstance(instance, WorkoutRoutine):
            CalendarEventService._sync_workout(instance)
        elif isinstance(instance, Medication):
            CalendarEventService._sync_medication(instance)
        elif isinstance(instance, MedicalAppointment):
            CalendarEventService._sync_medical(instance)
        elif isinstance(instance, GroceryList):
            CalendarEventService._sync_grocery(instance)
        elif isinstance(instance, Pet):
            CalendarEventService._sync_pet(instance)
        elif isinstance(instance, MealPlan):
            CalendarEventService._sync_meal_plan(instance)

    @staticmethod
    def delete(instance):
        ct = ContentType.objects.get_for_model(instance.__class__)
        SharedCalendarEvent.objects.filter(
            source_content_type=ct,
            source_object_id=instance.id,
        ).delete()

    @staticmethod
    def _create_event(household, title, start, end, description, instance):
        ct = ContentType.objects.get_for_model(instance.__class__)
        SharedCalendarEvent.objects.create(
            household=household,
            title=title,
            start_datetime=start,
            end_datetime=end,
            description=description,
            source_content_type=ct,
            source_object_id=instance.id,
        )

    @staticmethod
    def _generate_recurrences(start, frequency, until):
        if str(frequency) in (ChoreFrequency.DAILY, 'DAILY'):
            delta = timedelta(days=1)
        elif str(frequency) in (ChoreFrequency.WEEKLY, 'WEEKLY'):
            delta = timedelta(weeks=1)
        elif str(frequency) in (ChoreFrequency.MONTHLY, 'MONTHLY'):
            delta = relativedelta(months=1)
        else:
            return [start]

        dates, current = [], start
        while current <= until and len(dates) < 365:
            dates.append(current)
            current += delta
        return dates

    @staticmethod
    def _sync_chore(chore):
        start = chore.available_from or chore.created_at
        until = chore.available_until or start + timedelta(days=90)
        duration = (
            chore.available_until - chore.available_from
            if chore.available_from and chore.available_until
            else timedelta(hours=1)
        )

        for dt in CalendarEventService._generate_recurrences(start, chore.frequency, until):
            CalendarEventService._create_event(
                chore.household,
                f'Chore: {chore.title}',
                dt,
                dt + duration,
                chore.description,
                chore,
            )

    @staticmethod
    def _sync_workout(routine):
        today = timezone.localdate()
        end_date = today + timedelta(days=90)
        weekdays = {v: i for i, v in enumerate(DaysOfTheWeek.values)}
        for day_code in routine.schedule or []:
            first = timezone.make_aware(datetime.combine(today, time(6)))
            while first.weekday() != weekdays[day_code]:
                first += timedelta(days=1)
            while first.date() <= end_date:
                CalendarEventService._create_event(
                    routine.household,
                    f'Workout: {routine.title}',
                    first,
                    first + timedelta(hours=1),
                    routine.description,
                    routine,
                )
                first += timedelta(weeks=1)

    @staticmethod
    def _sync_medication(med):
        base = med.next_dose or med.created_at
        until = base + timedelta(days=30)
        for dt in CalendarEventService._generate_recurrences(base, med.frequency, until):
            CalendarEventService._create_event(
                med.household,
                f'Medication: {med.name}',
                dt,
                dt + timedelta(minutes=30),
                med.notes,
                med,
            )

    @staticmethod
    def _sync_medical(appointment):
        CalendarEventService._create_event(
            appointment.household,
            f'Appointment: {appointment.title}',
            appointment.appointment_datetime,
            appointment.appointment_datetime + timedelta(hours=1),
            appointment.description,
            appointment,
        )

    @staticmethod
    def _sync_grocery(grocery_list):
        start = grocery_list.run_datetime or grocery_list.created_at + timedelta(days=1)
        CalendarEventService._create_event(
            grocery_list.household,
            f'Grocery Run: {grocery_list.name}',
            start,
            start + timedelta(hours=2),
            '',
            grocery_list,
        )

    @staticmethod
    def _sync_pet_care(pet, label_prefix, instructions, frequency, times):
        # skip if block disabled
        if not frequency or not times:
            return

        base_date = timezone.localdate()
        until = base_date + timedelta(days=30)

        def _emit(dt):
            CalendarEventService._create_event(
                pet.household,
                f"{label_prefix}: {pet.name}",
                dt,
                dt + timedelta(minutes=30),
                instructions,
                pet,
            )

        for per_day_time in times:
            base = timezone.make_aware(datetime.combine(base_date, per_day_time))

            # ONCE  → one event right away
            if frequency == "ONCE":
                _emit(base)
                continue

            # DAILY / WEEKLY
            rec_freq = "DAILY" if frequency == "DAILY" else "WEEKLY"
            end = timezone.make_aware(datetime.combine(until, per_day_time))

            for dt in CalendarEventService._generate_recurrences(base, rec_freq, end):
                _emit(dt)

    # main entry for pets
    @staticmethod
    def _sync_pet(pet: Pet):
        CalendarEventService._sync_pet_care(
            pet,
            label_prefix="Feed",
            instructions=pet.food_instructions,
            frequency=pet.food_frequency,
            times=pet.food_time_objs,  # ← changed
        )
        CalendarEventService._sync_pet_care(
            pet,
            label_prefix="Water",
            instructions=pet.water_instructions,
            frequency=pet.water_frequency,
            times=pet.water_time_objs,  # ← changed
        )
        CalendarEventService._sync_pet_care(
            pet,
            label_prefix="Medication",
            instructions=pet.medication_instructions,
            frequency=pet.medication_frequency,
            times=pet.medication_time_objs,  # ← changed
        )

    @staticmethod
    def _sync_meal_plan(meal_plan):
        meal_time = MEAL_TIMES.get(meal_plan.meal_type)
        if not meal_time:
            return
        start = timezone.make_aware(datetime.combine(meal_plan.date, meal_time))
        CalendarEventService._create_event(
            meal_plan.household,
            f'{meal_plan.get_meal_type_display()}: {meal_plan.recipe_name}',
            start,
            start + timedelta(hours=1),
            meal_plan.notes,
            meal_plan,
        )