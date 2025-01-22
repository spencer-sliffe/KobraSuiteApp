# tests/test_frontend_courses_tab.py

import pytest
from django.urls import reverse
from rest_framework import status

from customer.models import SchoolProfile
from .factories import UniversityFactory, CourseFactory,AssignmentFactory, TopicFactory

from customer.tests.factories import UserFactory, SchoolProfileFactory

from .helpers import get_authenticated_client, create_school_profile_for_user

@pytest.mark.django_db
class TestFrontEndCoursesTab:
    def test_no_university_set_in_profile(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('course-search-local')
        response = client.get(url, {"query": "CS101"})
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "No university set in profile" in str(response.data)

    def test_search_courses_at_user_university(self, authenticated_client, user_factory, university_factory, course_factory):
        uni = university_factory()
        client, user = authenticated_client
        if not SchoolProfile.objects.filter(user=user).exists():
            profile = SchoolProfileFactory(user=user)
            profile.university = uni
            profile.save()
        else:
            profile = SchoolProfile.objects.get(user=user)
            profile.university = uni
            profile.save()
        c1 = course_factory(university=uni, course_code="CS101", title="Intro to CS", semester="Fall")
        c2 = course_factory(university=uni, course_code="CS102", title="Data Structures", semester="Spring")

        url = reverse('course-search-local')
        response = client.get(url, {"query": "CS1"})
        print(response)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        print(data)
        codes = [d["course_code"] for d in data]
        assert "CS101" in codes and "CS102" in codes

    def test_display_current_user_courses(self, authenticated_client, user_factory, university_factory, course_factory):
        uni = university_factory()
        client, user = authenticated_client
        if not SchoolProfile.objects.filter(user=user).exists():
            profile = SchoolProfileFactory(user=user)
            profile.university = uni
            profile.save()
        else:
            profile = SchoolProfile.objects.get(user=user)
            profile.university = uni
            profile.save()

        c1 = course_factory(university=uni)
        c2 = course_factory(university=uni)
        profile.courses.add(c1, c2)

        whoami_url = "/api/auth/whoami/"
        response = client.get(whoami_url)
        assert response.status_code == status.HTTP_200_OK
        user_data = response.json()["user"]
        print(user_data)

        expected_course_ids = {c1.id, c2.id}
        actual_course_ids = set(user_data["school_profile"]["courses"])
        assert actual_course_ids == expected_course_ids, f"Expected courses {expected_course_ids}, got {actual_course_ids}"

    def test_course_slug_details(self, authenticated_client, course_factory):
        client, user = authenticated_client
        course = course_factory(
            course_code="MATH240",
            title="Linear Algebra",
            professor_last_name="Smith",
            semester="Spring"
        )
        url = reverse('course-detail', args=[course.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["course_code"] == "MATH240"
        assert data["title"] == "Linear Algebra"
        assert data["professor_last_name"] == "Smith"
        assert data["semester"] == "Spring"
        assert "student_count" in data

    def test_course_slug_assignments_topics_chat_buttons(
        self, authenticated_client, assignment_factory, topic_factory, course_factory
    ):
        client, user = authenticated_client
        course = course_factory()
        a1 = assignment_factory(course=course, title="HW1")
        a2 = assignment_factory(course=course, title="HW2")
        t1 = topic_factory(course=course, name="Week 1: Intro")
        t2 = topic_factory(course=course, name="Week 2: Deep Dive")
        assign_list_url = reverse('assignments-list')
        response = client.get(assign_list_url, {"course": course.id})
        if response.status_code == status.HTTP_200_OK:
            data = response.json()
            titles = [item["title"] for item in data.get("results", data)]
            assert set(titles) == {"HW1", "HW2"}

        topics_list_url = reverse('topics-list')
        response = client.get(topics_list_url, {"course": course.id})
        if response.status_code == status.HTTP_200_OK:
            data = response.json()
            names = [item["name"] for item in data.get("results", data)]
            assert "Week 1: Intro" in names
            assert "Week 2: Deep Dive" in names
        new_topic_url = reverse('topics-list')
        topic_payload = {"course_id": course.id, "name": "Week 3: Extra"}
        topic_resp = client.post(new_topic_url, topic_payload, format='json')
        assert topic_resp.status_code == status.HTTP_201_CREATED

        new_assignment_url = reverse('assignments-list')
        assignment_payload = {
            "course_id": course.id,
            "title": "HW3",
            "due_date": "2026-01-01T12:00:00Z"
        }
        assignment_resp = client.post(new_assignment_url, assignment_payload, format='json')
        assert assignment_resp.status_code == status.HTTP_201_CREATED