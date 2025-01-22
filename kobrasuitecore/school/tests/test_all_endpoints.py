# tests/test_all_endpoint_edge_cases_and_responses.py

import pytest
from rest_framework import status
from django.urls import reverse
from .helpers import assert_error_response, create_school_profile_for_user


@pytest.mark.django_db
class TestAllEndpointEdgeCasesAndResponses:
    def test_university_detail_unauthenticated(self, api_client, university_factory):
        uni = university_factory()
        url = reverse('university-detail', args=[uni.id])
        response = api_client.get(url)
        assert_error_response(response, status.HTTP_401_UNAUTHORIZED, "Authentication credentials")

    def test_course_add_no_coursecode(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('course-add-new-course')
        payload = {
            "title": "Title with no code",
            "professor_last_name": "Jones"
        }
        response = client.post(url, payload, format='json')
        assert_error_response(response, status.HTTP_400_BAD_REQUEST, "Missing course_code")

    def test_assignment_create_past_due_date(self, authenticated_client, course_factory):
        client, user = authenticated_client
        course = course_factory()
        url = reverse('assignments-list')
        payload = {
            "course_id": course.id,
            "title": "Late assignment",
            "due_date": "2000-01-01T00:00:00Z"
        }
        response = client.post(url, payload, format='json')
        if response.status_code == status.HTTP_201_CREATED:
            pytest.fail("Expected an error for past due_date, but got 201.")
        else:
            assert response.status_code in [400, 422]

    def test_submission_create_no_assignment_id(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('submissions-list')
        payload = {"text_answer": "No assignment ID provided."}
        response = client.post(url, payload, format='json')
        assert_error_response(response, status.HTTP_400_BAD_REQUEST, "assignment_id")

    def test_study_document_invalid_topic(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('studydocuments-list')
        payload = {
            "topic_id": 9999,
            "title": "Doc with invalid topic"
        }
        response = client.post(url, payload, format='json')
        assert response.status_code in [status.HTTP_400_BAD_REQUEST, status.HTTP_404_NOT_FOUND]

    def test_remove_course_not_in_profile(self, authenticated_client, course_factory):
        client, user = authenticated_client
        course = course_factory()

        profile = create_school_profile_for_user(user)

        url = reverse('course-remove-course')
        response = client.post(url, {"course_id": course.id}, format='json')
        assert_error_response(response, status.HTTP_404_NOT_FOUND, "Course not in your courses")