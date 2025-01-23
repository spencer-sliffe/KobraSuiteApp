# customer/serializers/profile_serializers.py
from django.contrib.auth import get_user_model
from school.models import University, Course
from school.serializers.university_serializers import UniversitySerializer
from rest_framework import serializers

from ..models import UserProfile, SchoolProfile, WorkProfile

User = get_user_model()


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'date_of_birth', 'address', 'profile_picture', 'preferences',
        ]


class SchoolProfileSerializer(serializers.ModelSerializer):
    university_detail = UniversitySerializer(source='university', read_only=True)
    courses = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Course.objects.all(),
        required=False
    )

    class Meta:
        model = SchoolProfile
        fields = ['id', 'university', 'university_detail', 'courses']\

    def update(self, instance, validated_data):
        courses = validated_data.pop('courses', None)
        university = validated_data.pop('university', None)

        if university is not None:
            instance.university = university

        instance = super().update(instance, validated_data)

        if courses is not None:
            instance.courses.set(courses)

        instance.save()
        return instance


class WorkProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkProfile
        fields = [
            'id'
        ]