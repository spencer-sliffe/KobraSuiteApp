# school/views/assignment_views.py

import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated, DjangoModelPermissions
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination

from ..models import Assignment, Submission, Course
from ..serializers.assignment_serializers import (
    AssignmentSerializer,
    CreateAssignmentSerializer,
    SubmissionSerializer,
    SubmissionActionSerializer
)
from ..filters import AssignmentFilter, SubmissionFilter
from ..services.assignment_service import (
    create_assignment,
    submit_assignment,
)

logger = logging.getLogger(__name__)


class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all().select_related('course').prefetch_related('submissions')
    serializer_class = AssignmentSerializer
    permission_classes = [IsAuthenticated, DjangoModelPermissions]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = AssignmentFilter
    ordering_fields = ['due_date', 'created_at']
    ordering = ['due_date']

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return CreateAssignmentSerializer
        return AssignmentSerializer

    def get_queryset(self):
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        return Assignment.objects.filter(course__id=course_pk, course__university__id=university_pk).select_related('course').prefetch_related('submissions')

    def perform_create(self, serializer):
        # Access the parent course
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        course = get_object_or_404(Course, id=course_pk, university__id=university_pk)
        assignment, status_code = create_assignment(serializer.validated_data)
        logger.info(f"Assignment '{assignment.title}' created under Course '{course.title}' by User '{self.request.user.username}'.")
        # Return response directly
        return

    @action(detail=True, methods=['post'], url_path='submit', permission_classes=[IsAuthenticated], parser_classes=[MultiPartParser, FormParser])
    def submit_assignment_action(self, request, university_pk=None, course_pk=None, pk=None):
        assignment = self.get_object()
        serializer = SubmissionActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        submission_data = serializer.validated_data
        submission_data['assignment'] = assignment
        submission = submit_assignment(user=request.user, assignment=assignment, data=submission_data)
        if submission:
            submission_serializer = SubmissionSerializer(submission)
            logger.info(f"User '{request.user.username}' submitted Assignment '{assignment.title}'.")
            return Response(submission_serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response({"detail": "Submission could not be processed."}, status=status.HTTP_400_BAD_REQUEST)


class SubmissionViewSet(viewsets.ModelViewSet):
    queryset = Submission.objects.all().select_related('assignment', 'student')
    serializer_class = SubmissionSerializer
    permission_classes = [IsAuthenticated, DjangoModelPermissions]
    parser_classes = [MultiPartParser, FormParser]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = SubmissionFilter
    ordering_fields = ['submitted_at', 'created_at']
    ordering = ['-submitted_at']

    def get_queryset(self):
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        assignment_pk = self.kwargs.get('assignment_pk')
        return Submission.objects.filter(assignment__id=assignment_pk, assignment__course__id=course_pk, assignment__course__university__id=university_pk).select_related('assignment', 'student')

    def perform_create(self, serializer):
        university_pk = self.kwargs.get('university_pk')
        course_pk = self.kwargs.get('course_pk')
        assignment_pk = self.kwargs.get('assignment_pk')
        assignment = get_object_or_404(Assignment, id=assignment_pk, course__id=course_pk, course__university__id=university_pk)
        submission = serializer.save(student=self.request.user, assignment=assignment)
        logger.info(f"Submission '{submission.id}' for Assignment '{assignment.title}' by User '{self.request.user.username}'.")

    def perform_update(self, serializer):
        submission = serializer.save()
        logger.info(f"Submission '{submission.id}' updated by User '{self.request.user.username}'.")

    def perform_destroy(self, instance):
        logger.info(f"Submission '{instance.id}' deleted by User '{self.request.user.username}'.")
        instance.delete()

    @action(detail=True, methods=['post'], url_path='add_comment', permission_classes=[IsAuthenticated])
    def add_comment(self, request, university_pk=None, course_pk=None, assignment_pk=None, pk=None):
        submission = self.get_object()
        comment = request.data.get('comment', '').strip()
        if not comment:
            return Response({"detail": "Comment cannot be empty."}, status=status.HTTP_400_BAD_REQUEST)
        submission.comment = comment
        submission.save()
        serializer = self.get_serializer(submission)
        logger.info(f"Comment added to Submission '{submission.id}' by User '{request.user.username}'.")
        return Response(serializer.data, status=status.HTTP_200_OK)