# school/views/topic_views.py

from django.shortcuts import get_object_or_404
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, DjangoModelPermissions
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination

from ..models import Topic, StudyDocument, Course
from ..serializers.topic_serializers import TopicSerializer, StudyDocumentSerializer
from ..filters import TopicFilter
from ..services.topic_service import (
    create_study_document,
    update_study_document,
    delete_study_document
)

import logging

logger = logging.getLogger(__name__)


class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all().select_related('course').prefetch_related('documents')
    serializer_class = TopicSerializer
    permission_classes = [IsAuthenticated, DjangoModelPermissions]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = TopicFilter
    ordering_fields = ['name', 'created_at']
    ordering = ['-created_at']

    def get_queryset(self):
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        return self.queryset.filter(course__id=course_pk, course__university__id=university_pk)

    def perform_create(self, serializer):
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        course = get_object_or_404(Course, pk=course_pk, university__pk=university_pk)
        serializer.save(course=course, author=self.request.user)

    @action(detail=True, methods=['post'], url_path='add_study_document', permission_classes=[IsAuthenticated])
    def add_study_document(self, request, university_pk=None, course_pk=None, pk=None):
        topic = self.get_object()
        serializer = StudyDocumentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            study_document, status_code = create_study_document(serializer.validated_data, author=request.user)
            return Response(StudyDocumentSerializer(study_document).data, status=status.HTTP_201_CREATED)
        except Exception as e:
            logger.error(f"Error creating study document: {e}")
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['delete'], url_path='remove_study_document', permission_classes=[IsAuthenticated])
    def remove_study_document(self, request, university_pk=None, course_pk=None, pk=None):
        study_document_id = request.data.get('study_document_id')
        if not study_document_id:
            return Response({"detail": "Study Document ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        study_document = get_object_or_404(StudyDocument, pk=study_document_id, topic=self.get_object())
        try:
            delete_study_document(study_document)
            return Response({"detail": "Study Document deleted."}, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error deleting study document: {e}")
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['put'], url_path='update_study_document', permission_classes=[IsAuthenticated])
    def update_study_document_view(self, request, university_pk=None, course_pk=None, pk=None):
        study_document_id = request.data.get('study_document_id')
        if not study_document_id:
            return Response({"detail": "Study Document ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        study_document = get_object_or_404(StudyDocument, pk=study_document_id, topic=self.get_object())
        serializer = StudyDocumentSerializer(study_document, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        try:
            updated_document, status_code = update_study_document(study_document, serializer.validated_data)
            return Response(StudyDocumentSerializer(updated_document).data, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error updating study document: {e}")
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)