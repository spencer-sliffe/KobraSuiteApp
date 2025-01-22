# File location: school/serializers/course_serializers.py

import re
from django.utils import timezone
from rest_framework import serializers
from ..models import Course, University
from ..types import COURSE_CODE_REGEX


class CourseSerializer(serializers.ModelSerializer):
    student_count = serializers.IntegerField(read_only=True)
    university_id = serializers.PrimaryKeyRelatedField(
        source='university',
        queryset=University.objects.all(),
        write_only=True,
        required=False
    )
    university = serializers.SerializerMethodField()
    semester_display = serializers.CharField(read_only=True)

    class Meta:
        model = Course
        fields = [
            'id', 'course_code', 'professor_last_name', 'title',
            'semester_type', 'semester_year', 'department', 'semester_display',
            'created_at', 'student_count', 'university', 'university_id',
        ]

    def get_university(self, obj):
        if obj.university:
            return {
                "id": obj.university.id,
                "name": obj.university.name,
                "country": obj.university.country,
            }
        return None


class AddNewCourseSerializer(serializers.Serializer):
    course_code = serializers.CharField()
    title = serializers.CharField()
    professor_last_name = serializers.CharField()
    department = serializers.CharField()
    semester_type = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    semester_year = serializers.IntegerField(required=False, allow_null=True)

    def validate_course_code(self, value):
        if not COURSE_CODE_REGEX.match(value):
            raise serializers.ValidationError("Invalid course code format.")
        return value

    def validate(self, attrs):
        semester_type = attrs.get('semester_type')
        semester_year = attrs.get('semester_year')
        if (semester_type and not semester_year) or (semester_year and not semester_type):
            raise serializers.ValidationError("Both semester_type and semester_year must be provided together.")
        if semester_year is not None:
            current_year = timezone.now().year
            if semester_year < 1900 or semester_year > current_year + 10:
                raise serializers.ValidationError("Semester year must be a valid year.")
        return attrs


class CourseProfileActionSerializer(serializers.Serializer):
    course_id = serializers.IntegerField()