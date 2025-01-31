# File location: school/serializers/course_serializers.py

import re
from django.utils import timezone
from rest_framework import serializers
from ..models import Course, University
from ..types import COURSE_CODE_REGEX


class HouseholdSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Course
        fields = [
            'name', 'id', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_household(self, obj):
        if obj.household:
            return {
                "id": obj.household.id,
                "name": obj.household.name,
            }
        return None

    def create_household(self, obj):
        return


class HouseholdProfileActionSerializer(serializers.Serializer):
    household_id = serializers.IntegerField()