"""
------------------Prologue--------------------
File Name: assignment_serializers.py
Path: kobrasuitecore/school/serializers/assignment_serializers.py

Description:
Provides serializer classes for handling assignment and submission data.
AssignmentSerializer formats assignment data with nested course details and associated submissions.
CreateAssignmentSerializer offers a simplified interface for creating new assignments.
SubmissionSerializer validates and structures submission data including text answers, files, and optional comments.
SubmissionActionSerializer is used for partial updates to submission content.

Input:
Assignment and submission data submitted via API endpoints.

Output:
Validated and structured JSON representations for assignments and submissions.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/serializers/assignment_serializers.py

from rest_framework import serializers
from django.utils import timezone

from ..models import Assignment, Submission
from school.serializers.course_serializers import CourseSerializer


class AssignmentSerializer(serializers.ModelSerializer):
    course_detail = CourseSerializer(source='course', read_only=True)
    submissions = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = Assignment
        fields = [
            'id', 'title', 'due_date', 'created_at', 'course', 'course_detail', 'submissions'
        ]
        read_only_fields = ['created_at', 'submissions']

    def validate_due_date(self, value):
        if value < timezone.now():
            raise serializers.ValidationError("Due date cannot be in the past.")
        return value


class CreateAssignmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assignment
        fields = ['title', 'due_date', 'course']

    def validate_due_date(self, value):
        if value < timezone.now():
            raise serializers.ValidationError("Due date cannot be in the past.")
        return value


class SubmissionSerializer(serializers.ModelSerializer):
    student_detail = serializers.SerializerMethodField()
    assignment_detail = AssignmentSerializer(source='assignment', read_only=True)

    class Meta:
        model = Submission
        fields = [
            'id', 'assignment', 'assignment_detail', 'student', 'student_detail',
            'text_answer', 'submitted_at', 'answer_file', 'comment'
        ]
        read_only_fields = ['student', 'submitted_at', 'assignment_detail', 'student_detail']

    def get_student_detail(self, obj):
        return {
            "id": obj.student.id,
            "username": obj.student.username,
            "email": obj.student.email,
        }

    def validate(self, attrs):
        if not attrs.get('text_answer') and not attrs.get('answer_file'):
            raise serializers.ValidationError("Either text_answer or answer_file must be provided.")
        return attrs

    def create(self, validated_data):
        assignment = validated_data.get('assignment')
        if not assignment:
            raise serializers.ValidationError("Assignment is required.")
        return super().create(validated_data)

    def update(self, instance, validated_data):
        return super().update(instance, validated_data)


class SubmissionActionSerializer(serializers.Serializer):
    text_answer = serializers.CharField(required=False, allow_blank=True)
    answer_file = serializers.FileField(required=False)
    comment = serializers.CharField(required=False, allow_blank=True)