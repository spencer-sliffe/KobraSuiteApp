# tests/test_frontend_university_tab.py

import pytest
from django.urls import reverse
from rest_framework import status

from customer.models import SchoolProfile
from .factories import UniversityFactory, CourseFactory
from .helpers import get_authenticated_client, create_school_profile_for_user
from customer.tests.factories import UserFactory, SchoolProfileFactory


@pytest.mark.django_db
class TestFrontEndUniversityTab:
    def test_search_universities_return_name_and_location(
        self, api_client
    ):
        url = reverse('university-search-universities')
        response = api_client.get(url, {"name": "MIT"})
        if response.status_code == status.HTTP_200_OK:
            assert isinstance(response.data, list), "Should return a list of universities"
            for uni_item in response.data:
                assert "name" in uni_item
                assert "country" in uni_item

    def test_user_has_university_chat_button_displayed(
        self, api_client, university_factory, user_factory
    ):
        user = user_factory()
        profile = create_school_profile_for_user(user, university_factory=university_factory)
        assert profile.university is not None, "User has a University set."

    def test_user_has_no_university_no_chat_button(
        self, api_client, user_factory
    ):
        user = user_factory()
        profile = create_school_profile_for_user(user, university_factory=None)
        assert profile.university is None, "User has no University."

    def test_university_slug_details(
        self, authenticated_client, university_factory
    ):
        uni = university_factory()
        for _ in range(2):
            CourseFactory(university=uni)
        client, user = authenticated_client
        if not SchoolProfile.objects.filter(user=user).exists():
            school_profile = SchoolProfileFactory(user=user, university = uni)
            school_profile.university = uni
            school_profile.save()
        else:
            school_profile = SchoolProfile.objects.get(user=user)
            school_profile.university = uni
            school_profile.save()
        url = reverse('university-detail', args=[uni.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data['id'] == uni.id
        assert data['course_count'] == 2
        assert data['student_count'] == 1

    def test_list_university_courses_sorted(
        self, authenticated_client, university_factory
    ):
        uni = university_factory()
        c1 = CourseFactory(university=uni, course_code="CS101", semester="Fall")
        c2 = CourseFactory(university=uni, course_code="CS101", semester="Spring")
        c3 = CourseFactory(university=uni, course_code="CS100", semester="Fall")
        client, user = authenticated_client
        url = reverse('university-list-university-courses', args=[uni.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        codes_semesters = [(d['course_code'], d['semester']) for d in data]
        assert codes_semesters == [
            ("CS100", "Fall"),
            ("CS101", "Fall"),
            ("CS101", "Spring"),
        ]

    def test_set_university_action(self, authenticated_client, university_factory):
        client, user = authenticated_client
        uni = university_factory()
        url = reverse('university-set-as-my-university', args=[uni.id])
        response = client.post(url)
        assert response.status_code == status.HTTP_200_OK
        user.refresh_from_db()
        assert user.school_profile.university == uni

    def test_remove_university_action(self, authenticated_client, university_factory):
        client, user = authenticated_client
        uni = university_factory()
        sp = create_school_profile_for_user(user, university_factory=None)
        sp.university = uni
        sp.save()
        url = reverse('university-remove-as-my-university', args=[uni.id])
        response = client.post(url)
        assert response.status_code == status.HTTP_200_OK
        sp.refresh_from_db()
        assert sp.university is None