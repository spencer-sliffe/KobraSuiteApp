"""
------------------Prologue--------------------
File Name: topic_serializers.py
Path: kobrasuitecore/school/serializers/topic_serializers.py

Description:
Defines serializers for managing topics and associated study documents.
TopicSerializer formats topic data with nested course details.
StudyDocumentSerializer validates study document submissions and includes author information.

Input:
Topic and study document data from client submissions.

Output:
Structured and validated JSON responses representing topics and study documents.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# school/serializers/topic_serializers.py

from rest_framework import serializers

from ..models import Topic, StudyDocument
from school.serializers.course_serializers import CourseSerializer


class TopicSerializer(serializers.ModelSerializer):
    course_detail = CourseSerializer(source='course', read_only=True)
    study_documents = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = Topic
        fields = [
            'id', 'name', 'course', 'course_detail', 'created_at', 'study_documents'
        ]
        read_only_fields = ['created_at', 'study_documents']

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Topic name cannot be empty.")
        return value


class StudyDocumentSerializer(serializers.ModelSerializer):
    topic_detail = TopicSerializer(source='topic', read_only=True)
    author_detail = serializers.SerializerMethodField()

    class Meta:
        model = StudyDocument
        fields = [
            'id', 'topic', 'topic_detail', 'author', 'author_detail',
            'file', 'title', 'created_at'
        ]
        read_only_fields = ['author', 'created_at', 'topic_detail', 'author_detail']

    def get_author_detail(self, obj):
        return {
            "id": obj.author.id,
            "username": obj.author.username,
            "email": obj.author.email,
        }

    def validate_file(self, value):
        if not value:
            raise serializers.ValidationError("File is required.")
        return value

    def validate_title(self, value):
        if not value.strip():
            raise serializers.ValidationError("Title cannot be empty.")
        return value