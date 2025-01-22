# school/services/course_service.py
import logging
from typing import Tuple, Any, Dict
from django.db import transaction
from rest_framework import status
from ..models import Course
from ..serializers.course_serializers import CourseSerializer

logger = logging.getLogger(__name__)


def create_course_in_university(university, course_data: dict) -> Tuple[Course, bool]:
    course_code = course_data.get('course_code')
    existing_course = Course.objects.filter(university=university, course_code=course_code).first()
    if existing_course:
        return existing_course, False
    with transaction.atomic():
        new_course = Course.objects.create(university=university, **course_data)
    logger.info(f"[COURSE_SERVICE] Created new course '{new_course.title}' (code: {new_course.course_code}) in University '{university.name}'.")
    return new_course, True


def search_course_in_university(university, query: str) -> Tuple[Any, int]:
    courses = Course.objects.filter(university=university).filter(course_code__icontains=query) | \
              Course.objects.filter(university=university).filter(title__icontains=query) | \
              Course.objects.filter(university=university).filter(professor_last_name__icontains=query)
    courses = courses.distinct()
    serializer = CourseSerializer(courses, many=True)
    logger.debug(f"[COURSE_SERVICE] Found {courses.count()} courses matching '{query}' in '{university.name}'.")
    return serializer.data, status.HTTP_200_OK


def add_course_to_school_profile(school_profile, course_id: int) -> Tuple[Dict[str, Any], int]:
    try:
        course = Course.objects.get(id=course_id, university=school_profile.university)
    except Course.DoesNotExist:
        logger.error(f"[COURSE_SERVICE] Course with ID {course_id} does not exist in the user's university.")
        return {"detail": "Course does not exist in your university."}, status.HTTP_404_NOT_FOUND
    school_profile.courses.add(course)
    logger.info(f"[COURSE_SERVICE] Added Course ID {course_id} to SchoolProfile ID {school_profile.id}.")
    return {"detail": "Course added to your profile."}, status.HTTP_200_OK


def remove_course_from_school_profile(school_profile, course_id: int) -> Tuple[Dict[str, Any], int]:
    try:
        course = Course.objects.get(id=course_id, university=school_profile.university)
    except Course.DoesNotExist:
        logger.error(f"[COURSE_SERVICE] Course with ID {course_id} does not exist in the user's university.")
        return {"detail": "Course does not exist in your university."}, status.HTTP_404_NOT_FOUND
    if course in school_profile.courses.all():
        school_profile.courses.remove(course)
        logger.info(f"[COURSE_SERVICE] Removed Course ID {course_id} from SchoolProfile ID {school_profile.id}.")
        return {"detail": "Course removed from your profile."}, status.HTTP_200_OK
    else:
        logger.warning(f"[COURSE_SERVICE] Course ID {course_id} not associated with SchoolProfile ID {school_profile.id}.")
        return {"detail": "Course not associated with your profile."}, status.HTTP_400_BAD_REQUEST