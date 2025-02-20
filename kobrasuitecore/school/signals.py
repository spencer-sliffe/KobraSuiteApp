"""
------------------Prologue--------------------
File Name: signals.py
Path: kobrasuitecore/school/signals.py

Description:
Registers signal handlers to log significant events within the school module.
Monitors creation events for University, Course, Assignment, Submission, and DiscussionThread.
Also logs many-to-many changes in course-student relationships.

Input:
Model save events and m2m_changed signals triggered by data modifications.

Output:
Log entries detailing creation and update events for school-related models.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/signals.py
import logging
from django.db.models.signals import post_save, m2m_changed
from django.dispatch import receiver
from django.conf import settings
from .models import University, Course, Assignment, Submission, DiscussionThread

logger = logging.getLogger(__name__)


@receiver(post_save, sender=University)
def university_created(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New University created: {instance.name} (ID: {instance.id}, Country: {instance.country})")


@receiver(post_save, sender=Course)
def course_created(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New Course created: '{instance.title}' (Code: {instance.course_code}, Professor: {instance.professor_last_name}, Department: {instance.department}, University: {instance.university})")


@receiver(post_save, sender=Assignment)
def assignment_created(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New Assignment created: '{instance.title}' for Course '{instance.course.title}'.")


@receiver(post_save, sender=Submission)
def submission_created(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New Submission by {instance.student.username} for Assignment '{instance.assignment.title}'.")


@receiver(post_save, sender=DiscussionThread)
def discussion_thread_created(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New Discussion Thread created: '{instance.title}' (Scope: {instance.scope}, Scope ID: {instance.scope_id}).")


@receiver(m2m_changed, sender=Course.students.through)
def course_students_changed(sender, instance, action, pk_set, **kwargs):
    if action == "post_add":
        logger.info(f"Students {pk_set} added to Course '{instance.title}' (ID: {instance.id}).")
    elif action == "post_remove":
        logger.info(f"Students {pk_set} removed from Course '{instance.title}' (ID: {instance.id}).")