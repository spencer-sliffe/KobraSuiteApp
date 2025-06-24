from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import JSONParser
from django.contrib.auth import get_user_model

from school.models import University
from ai.serializers.chatgpt_serializers import (
    CourseVerificationSerializer,
    ChatRequestSerializer,
    ChatResponseSerializer,
    ChatLogSerializer,
)
from ai.services.chatgpt_services import (
    gather_conversation_for_user,
    communicate_with_openai,
    verify_course_existence,
)
from ai.models import ChatLog
from ai.permissions import IsAuthenticatedAndActive

User = get_user_model()


class ChatBotViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticatedAndActive]
    parser_classes = [JSONParser]

    @action(detail=False, methods=['get'], url_path='conversation')
    def conversation(self, request):
        logs = ChatLog.objects.filter(user_id=request.user.id).order_by('-timestamp')[:20][::-1]
        serializer = ChatLogSerializer(logs, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='chat')
    def chat(self, request):
        serializer = ChatRequestSerializer(data=request.data)
        if serializer.is_valid():
            user_message = serializer.validated_data['message']
            context_messages = gather_conversation_for_user(request.user.id)
            bot_response = communicate_with_openai(user_message, context_messages)
            ChatLog.objects.create(
                user=request.user,
                user_message=user_message,
                bot_response=bot_response
            )
            response_serializer = ChatResponseSerializer({'response': bot_response})
            return Response(response_serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class VerifyCourseViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticatedAndActive]

    @action(detail=False, methods=['post'])
    def verify_course(self, request, user_pk, profile_pk, school_profile_pk, university_pk):
        serializer = CourseVerificationSerializer(data=request.data)
        if serializer.is_valid():
            university = University.objects.get(pk=university_pk)
            course_code = serializer.validated_data['course_code']
            course_title = serializer.validated_data['course_title']
            professor_last_name = serializer.validated_data['professor_last_name']
            semester_type = serializer.validated_data['semester_type']
            department = serializer.validated_data['department']
            result = verify_course_existence(
                university.name if university else '',
                course_code,
                course_title,
                professor_last_name,
                department,
                semester_type,
            )
            return Response(result, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
