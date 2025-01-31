from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.utils import timezone

from hq.models import UserProfile
from .types import NotificationType, ActionType


class Notification(models.Model):
    recipient = models.ForeignKey(
        UserProfile,
        related_name='notifications',
        on_delete=models.CASCADE
    )
    sender_content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        related_name='notification_senders'
    )
    sender_object_id = models.PositiveIntegerField()
    sender = GenericForeignKey('sender_content_type', 'sender_object_id')
    target_content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        related_name='notification_targets'
    )
    target_object_id = models.PositiveIntegerField()
    target = GenericForeignKey('target_content_type', 'target_object_id')
    title = models.CharField(max_length=200)
    read = models.BooleanField(default=False)
    notification_type = models.CharField(
        max_length=50,
        choices=NotificationType.choices,
        default=NotificationType.PROFILE
    )
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Notification({self.notification_type}) for {self.recipient.user.username}"

    class Meta:
        ordering = ['-created_at']


class NotificationAction(models.Model):
    notification = models.ForeignKey(
        Notification,
        related_name='actions',
        on_delete=models.CASCADE
    )
    action_type = models.CharField(
        max_length=50,
        choices=ActionType.choices,
        default=ActionType.DO_NOTHING
    )
    action_value = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Action({self.action_type}) for Notification({self.notification.id})"