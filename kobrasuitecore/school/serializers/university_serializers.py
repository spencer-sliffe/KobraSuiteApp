"""
------------------Prologue--------------------
File Name: university_serializers.py
Path: kobrasuitecore/school/serializers/university_serializers.py

Description:
Provides serializers for university data management.
UniversitySerializer formats university details along with computed student and course counts.
SetUniversitySerializer validates and processes input data for setting university information.

Input:
University data provided by client applications.

Output:
Structured and validated JSON representations of university information.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/serializers/university_serializers.py
from rest_framework import serializers
from ..models import University


class UniversitySerializer(serializers.ModelSerializer):
    student_count = serializers.IntegerField(read_only=True)
    course_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = University
        fields = [
            'id', 'name', 'country', 'domain', 'website',
            'state_province', 'student_count', 'course_count'
        ]

    def validate_name(self, value):
        if not value:
            raise serializers.ValidationError("University name is required.")
        return value

    def validate(self, data):
        name = data.get("name")
        country = data.get("country")
        if name and country and len(name) < 2:
            raise serializers.ValidationError("University name must be at least 2 characters long.")
        return data


class SetUniversitySerializer(serializers.Serializer):
    name = serializers.CharField(required=True)
    country = serializers.CharField(required=True)
    domain = serializers.CharField(required=False, allow_blank=True)
    website = serializers.CharField(required=False, allow_blank=True)

    def validate(self, attrs):
        if not attrs.get('name') or not attrs.get('country'):
            raise serializers.ValidationError("Name and country are required.")
        return attrs