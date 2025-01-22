from django.db import models
from django.conf import settings
from .types import NotificationType
from django.utils import timezone


class Notification(models.Model):
    """
    Cross-module user notifications (finance alert, chore reminder, etc.).
    """
    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    title = models.CharField(max_length=200)
    message = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    read = models.BooleanField(default=False)
    notification_type = models.CharField(
        max_length=50,
        choices=NotificationType.choices,
        default=NotificationType.OTHER
    )

    def __str__(self):
        return f"Notification({self.notification_type}) for {self.recipient.username}"

    class Meta:
        ordering = ['-created_at']


class NotificationPreference(models.Model):
    """
    Stores user preferences for receiving notifications (email, push, etc.).
    """
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE
    )
    email_notifications = models.BooleanField(default=True)
    push_notifications = models.BooleanField(default=True)
    sms_notifications = models.BooleanField(default=False)

    def __str__(self):
        return f"Preferences of {self.user.username}"