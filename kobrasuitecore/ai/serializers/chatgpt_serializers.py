from rest_framework import serializers

from school.serializers.university_serializers import UniversitySerializer
from ai.models import ChatLog


class ChatRequestSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=1000)


class ChatResponseSerializer(serializers.Serializer):
    response = serializers.CharField()


class ChatLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatLog
        fields = ['id', 'user', 'user_message', 'bot_response', 'timestamp']
        read_only_fields = ['id', 'user', 'bot_response', 'timestamp']


class CourseVerificationSerializer(serializers.Serializer):
    university = UniversitySerializer(read_only=True)
    course_code = serializers.CharField(max_length=50)
    course_title = serializers.CharField(max_length=200)
    professor_last_name = serializers.CharField(max_length=100)
    department = serializers.CharField(max_length=100)
    semester_type = serializers.CharField(max_length=10)
    semester_year = serializers.IntegerField(required=False)