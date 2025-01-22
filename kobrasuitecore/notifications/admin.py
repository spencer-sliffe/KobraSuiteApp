# notifications/admin.py

from django.contrib import admin
from .models import Notification, NotificationPreference

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'notification_type', 'recipient', 'created_at', 'read')
    search_fields = ('title', 'recipient__username')
    list_filter = ('notification_type', 'created_at', 'read')

@admin.register(NotificationPreference)
class NotificationPreferenceAdmin(admin.ModelAdmin):
    list_display = ('user', 'email_notifications', 'push_notifications', 'sms_notifications')
    search_fields = ('user__username',)
