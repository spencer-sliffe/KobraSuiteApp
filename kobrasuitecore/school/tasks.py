"""
------------------Prologue--------------------
File Name: tasks.py
Path: kobrasuitecore/school/tasks.py

Description:
Defines asynchronous Celery tasks for background processing within the school module.
Tasks include synchronizing universities from an external API, cleaning up old submissions,
and sending assignment reminders to students.

Input:
Scheduled task triggers with optional parameters such as cleanup days or reminder intervals.

Output:
Background operations that update the database and log task outcomes.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/tasks.py
import logging
import datetime
from celery import shared_task
from django.utils import timezone
from rest_framework import status
from .services.university_service import search_universities
from .models import Submission, Assignment

logger = logging.getLogger(__name__)


@shared_task
def sync_universities_task(name=None, country=None):
    data, status_code = search_universities(name, country)
    if status_code == status.HTTP_200_OK:
        logger.info(f"Successfully synced universities. Count: {len(data)}")
    else:
        logger.error(f"Failed to sync universities. Response: {data}")


@shared_task
def clean_old_submissions(days=180):
    cutoff_date = timezone.now() - datetime.timedelta(days=days)
    old_submissions = Submission.objects.filter(submitted_at__lt=cutoff_date)
    count = old_submissions.count()
    old_submissions.delete()
    logger.info(f"Cleaned up {count} submissions older than {days} days.")


@shared_task
def remind_upcoming_assignments(hours_until_due=24):
    now = timezone.now()
    cutoff = now + datetime.timedelta(hours=hours_until_due)
    upcoming_assignments = Assignment.objects.filter(due_date__lte=cutoff, due_date__gte=now)
    for assignment in upcoming_assignments:
        for student in assignment.course.students.all():
            logger.info(f"Reminder sent to {student.username} for assignment '{assignment.title}'.")