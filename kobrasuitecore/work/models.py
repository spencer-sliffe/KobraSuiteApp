"""
------------------Prologue--------------------
File Name: models.py
Path: kobrasuitecore/work/models.py

Description:
Defines the WorkPlace model representing a workplace environment.
Includes fields for name, field, website, invite_code, owner, identity_image, and creation timestamp.
Automatically generates a unique invite code if not provided and computes the member_count based on related work profiles.

Input:
WorkPlace data submitted via forms or API endpoints.

Output:
Database table representation for WorkPlace with automated invite code generation and a computed member count.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.db import models
from django.conf import settings
from django.utils import timezone
import secrets

from work.types import WorkPlaceField


class WorkPlace(models.Model):
    name = models.CharField(max_length=100)
    field = models.CharField(max_length=50, choices=WorkPlaceField.choices, default=WorkPlaceField.OTHER)
    website = models.URLField(max_length=500, blank=True, null=True)
    invite_code = models.CharField(max_length=20, unique=True, blank=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='owned_workplaces')
    identity_image = models.ImageField(upload_to='workplace_identity/', blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)

    def save(self, *args, **kwargs):
        if not self.invite_code:
            code = secrets.token_urlsafe(8)[:20]
            while WorkPlace.objects.filter(invite_code=code).exists():
                code = secrets.token_urlsafe(8)[:20]
            self.invite_code = code
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    @property
    def member_count(self):
        return self.work_profiles.count()

#
# class Project(models.Model):
#     """
#     A project within a work context, possibly linked to a Team.
#     """
#     team = models.ForeignKey(
#         Team,
#         on_delete=models.CASCADE,
#         null=True,
#         blank=True,
#         related_name='projects'
#     )
#     name = models.CharField(max_length=200)
#     description = models.TextField(null=True, blank=True)
#     start_date = models.DateField()
#     end_date = models.DateField(null=True, blank=True)
#     is_active = models.BooleanField(default=True)
#
#     def __str__(self):
#         return self.name
#
#
# class WorkTask(models.Model):
#     """
#     Individual tasks under a project.
#     """
#     project = models.ForeignKey(
#         Project,
#         on_delete=models.CASCADE,
#         related_name='tasks'
#     )
#     title = models.CharField(max_length=200)
#     description = models.TextField(null=True, blank=True)
#     assignee = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.SET_NULL,
#         null=True,
#         blank=True,
#         related_name='assigned_tasks'
#     )
#     status = models.CharField(
#         max_length=50,
#         choices=WorkTaskStatus.choices,
#         default=WorkTaskStatus.TODO
#     )
#     priority = models.IntegerField(default=1)
#     due_date = models.DateField(null=True, blank=True)
#     created_at = models.DateTimeField(default=timezone.now)
#
#     def __str__(self):
#         return f"{self.title} ({self.project.name})"
#
#
# class Timesheet(models.Model):
#     """
#     Logs hours worked by a user on a specific task or project.
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='timesheets'
#     )
#     project = models.ForeignKey(
#         Project,
#         on_delete=models.CASCADE,
#         related_name='timesheets'
#     )
#     task = models.ForeignKey(
#         WorkTask,
#         on_delete=models.CASCADE,
#         null=True,
#         blank=True,
#         related_name='timesheets'
#     )
#     date = models.DateField()
#     hours_worked = models.DecimalField(max_digits=5, decimal_places=2, default=0.00)
#     notes = models.TextField(null=True, blank=True)
#
#     def __str__(self):
#         return f"{self.user.username} - {self.hours_worked}h on {self.date}"
#
#
# class Meeting(models.Model):
#     """
#     Represents a scheduled meeting for a project or team.
#     """
#     project = models.ForeignKey(
#         Project,
#         on_delete=models.CASCADE,
#         null=True,
#         blank=True,
#         related_name='meetings'
#     )
#     team = models.ForeignKey(
#         Team,
#         on_delete=models.CASCADE,
#         null=True,
#         blank=True,
#         related_name='meetings'
#     )
#     title = models.CharField(max_length=200)
#     start_time = models.DateTimeField()
#     end_time = models.DateTimeField()
#     location = models.CharField(max_length=200, null=True, blank=True)
#     created_at = models.DateTimeField(default=timezone.now)
#     attendees = models.ManyToManyField(
#         settings.AUTH_USER_MODEL,
#         related_name='meetings',
#         blank=True
#     )
#
#     def __str__(self):
#         return f"{self.title}"
#
#
# class MeetingNote(models.Model):
#     """
#     Notes or minutes from a meeting.
#     """
#     meeting = models.OneToOneField(
#         Meeting,
#         on_delete=models.CASCADE,
#         related_name='notes'
#     )
#     content = models.TextField()
#     created_at = models.DateTimeField(default=timezone.now)
#     updated_at = models.DateTimeField(auto_now=True)
#
#     def __str__(self):
#         return f"Notes for: {self.meeting.title}"
#
