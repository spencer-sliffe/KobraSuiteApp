from rest_framework import serializers
from homelife.models import SharedCalendarEvent


class SharedCalendarEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = SharedCalendarEvent
        fields = '__all__'