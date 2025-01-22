# tests/test_Course.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import CourseFactory, UniversityFactory
from customer.tests.factories import UserFactory, SchoolProfileFactory
from .helpers import get_authenticated_client, create_school_profile_for_user

@pytest.mark.django_db
class TestCourseEndpoints:
    def test_retrieve_course_success(self, authenticated_client, course_factory):
        client, user = authenticated_client
        course = course_factory()
        url = reverse('course-detail', args=[course.id])
        response = client.get(url)
        assert response.status_code == 200, response.data
        assert response.data['id'] == course.id
        assert response.data['title'] == course.title

    def test_search_local_course_no_university(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('course-search-local')
        response = client.get(url, {"query": "CS101"})
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "No university set in profile" in str(response.data)

    def test_search_local_course_success(self, api_client, user_factory, university_factory, course_factory):
        user = user_factory()
        profile = create_school_profile_for_user(user, university_factory=university_factory)
        course1 = course_factory(university=profile.university, course_code="CS101")
        course2 = course_factory(university=profile.university, course_code="CS102")
        course_factory(course_code="CS999")

        client = get_authenticated_client(api_client, user)
        url = reverse('course-search-local')
        response = client.get(url, {"query": "CS10"})
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        codes = [c['course_code'] for c in data]
        assert "CS101" in codes
        assert "CS102" in codes
        assert len(data) == 2

    def test_add_new_course_success(self, api_client, user_factory, university_factory):
        user = user_factory()
        profile = create_school_profile_for_user(user, university_factory=university_factory)

        client = get_authenticated_client(api_client, user)
        url = reverse('course-add-new-course')
        body = {
            "course_code": "EECS101",
            "title": "Intro to EECS",
            "professor_last_name": "Smith",
            "description": "Some description",
            "semester": "Fall"
        }
        response = client.post(url, body, format='json')
        assert response.status_code in [status.HTTP_201_CREATED, status.HTTP_200_OK], response.data
        profile.refresh_from_db()
        created_course = profile.courses.first()
        assert created_course is not None
        assert created_course.course_code == "EECS101"

    def test_add_to_profile_with_valid_course(self, api_client, user_factory, course_factory):
        user = user_factory()
        profile = create_school_profile_for_user(user)
        course = course_factory()
        profile.university = course.university
        profile.save()

        client = get_authenticated_client(api_client, user)
        url = reverse('course-add-to-profile')
        response = client.post(url, {"course_id": course.id}, format='json')
        assert response.status_code == status.HTTP_200_OK, response.data
        profile.refresh_from_db()
        assert course in profile.courses.all()

    def test_remove_course_from_profile(self, api_client, user_factory, course_factory):
        user = user_factory()
        profile = create_school_profile_for_user(user)
        course = course_factory()
        profile.university = course.university
        profile.save()
        profile.courses.add(course)

        client = get_authenticated_client(api_client, user)
        url = reverse('course-remove-course')
        response = client.post(url, {"course_id": course.id}, format='json')
        assert response.status_code == status.HTTP_200_OK
        profile.refresh_from_db()
        assert course not in profile.courses.all()