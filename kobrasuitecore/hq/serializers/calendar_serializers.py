from rest_framework import serializers
from hq.models import CalendarEvent


class CalendarEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalendarEvent
        fields = [
            'id',
            'profile',
            'module_type',
            'title',
            'description',
            'start_datetime',
            'end_datetime',
            'is_all_day',
            'created_at',
            'updated_at',
        ]