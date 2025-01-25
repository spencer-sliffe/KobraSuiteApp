# File location: school/views/course_views.py

from django.shortcuts import get_object_or_404
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination
import logging

from ..models import Course, University
from ..serializers.course_serializers import (
    CourseSerializer,
    AddNewCourseSerializer,
    CourseProfileActionSerializer
)
from ..filters import CourseFilter
from ..services.course_service import (
    create_course_in_university,
    add_course_to_school_profile,
    remove_course_from_school_profile,
    search_course_in_university
)

logger = logging.getLogger(__name__)


class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all().select_related('university').prefetch_related('students')
    serializer_class = CourseSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = CourseFilter
    ordering_fields = ['title', 'course_code', 'semester_type', 'semester_year']
    ordering = ['title']

    def get_queryset(self):
        university_pk = self.kwargs.get('university_pk')
        return self.queryset.filter(university__id=university_pk)

    def perform_create(self, serializer):
        university_pk = self.kwargs.get('university_pk')
        university = get_object_or_404(University, pk=university_pk)
        course = serializer.save(university=university)
        logger.info(
            f"Course created: {course.title} under University {university.name} by {self.request.user.username}"
        )

    @action(detail=False, methods=['post'], url_path='add_new_course')
    def add_new_course(self, request, university_pk=None, user_pk=None, school_profile_pk=None):
        serializer = AddNewCourseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        course_data = serializer.validated_data

        university = get_object_or_404(University, pk=university_pk)

        try:
            course, created = create_course_in_university(university, course_data)

            school_profile = getattr(request.user, 'school_profile', None)
            if not school_profile:
                return Response(
                    {"detail": "You do not have a valid school profile."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            data, code = add_course_to_school_profile(school_profile, course.id)

            detail_msg = "Course created and added." if created else "Course already existed; added to profile."
            detail_msg = f"{detail_msg} ({data.get('detail', '')})"
            overall_status = status.HTTP_201_CREATED if created else status.HTTP_200_OK

            course_json = CourseSerializer(course).data
            return Response(
                {"detail": detail_msg, "course": course_json},
                status=overall_status
            )

        except Exception as e:
            logger.error(f"Error in adding course: {e}")
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='search', name='search_course')
    def search_courses(self, request, university_pk=None, user_pk=None, school_profile_pk=None):
        university = get_object_or_404(University, pk=university_pk)
        query = request.query_params.get('query', '')
        data, code = search_course_in_university(university, query)
        return Response(data, status=code)

    @action(detail=False, methods=['post'], url_path='add_course_to_profile')
    def add_course_to_profile(self, request, university_pk=None):
        serializer = CourseProfileActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        course_id = serializer.validated_data.get('course_id')
        school_profile = getattr(request.user, 'school_profile', None)
        if not school_profile or not school_profile.university:
            return Response(
                {"detail": "No valid school profile or no university set in profile."},
                status=status.HTTP_400_BAD_REQUEST
            )
        data, code = add_course_to_school_profile(school_profile, course_id)
        return Response(data, status=code)

    @action(detail=False, methods=['post'], url_path='remove_course_from_profile')
    def remove_course_from_profile(self, request, university_pk=None):
        serializer = CourseProfileActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        course_id = serializer.validated_data.get('course_id')
        school_profile = getattr(request.user, 'school_profile', None)
        if not school_profile:
            return Response({"detail": "School profile not found."}, status=status.HTTP_404_NOT_FOUND)
        data, code = remove_course_from_school_profile(school_profile, course_id)
        return Response(data, status=code)