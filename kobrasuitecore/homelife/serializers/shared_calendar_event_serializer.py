from rest_framework import serializers
from homelife.models import SharedCalendarEvent


class SharedCalendarEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = SharedCalendarEvent
        fields = [
            "id",
            "household",
            "title",
            "start_datetime",
            "end_datetime",
            "description",
            "location",
            "source_content_type",
            "source_object_id",
        ]

        read_only_fields = ["source_content_type", "source_object_id"]
