# tests/test_assignment.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import AssignmentFactory, CourseFactory, SubmissionFactory
from customer.tests.factories import UserFactory
from .helpers import get_authenticated_client


@pytest.mark.django_db
class TestAssignmentEndpoints:
    def test_create_assignment_no_course_id(self, authenticated_client):

        client, user = authenticated_client
        url = reverse('assignments-list')
        payload = {
            "title": "Homework 1",
            "due_date": "2025-10-10T23:59:59Z"
        }
        response = client.post(url, payload, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "Missing course_id" in str(response.data)

    def test_create_assignment_success(self, api_client, user_factory, course_factory):
        user = user_factory()
        course = course_factory()
        client = get_authenticated_client(api_client, user)
        url = reverse('assignments-list')
        payload = {
            "course_id": course.id,
            "title": "Homework 2",
            "due_date": "2025-10-11T23:59:59Z"
        }
        response = client.post(url, payload, format='json')
        assert response.status_code == status.HTTP_201_CREATED, response.data
        data = response.json()
        assert data["course"]["id"] == course.id
        assert data["title"] == "Homework 2"

    def test_list_assignments(self, authenticated_client, assignment_factory):
        client, user = authenticated_client
        assignment_factory.create_batch(3)
        url = reverse('assignments-list')
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data["results"]) == 3

    def test_retrieve_assignment_detail(self, authenticated_client, assignment_factory):
        client, user = authenticated_client
        assignment = assignment_factory()
        url = reverse('assignments-detail', args=[assignment.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data["id"] == assignment.id

    def test_list_submissions_for_assignment(self, authenticated_client, assignment_factory, submission_factory):
        client, user = authenticated_client
        assignment = assignment_factory()
        submission_factory(assignment=assignment)
        submission_factory(assignment=assignment)
        url = reverse('assignments-list-submissions', args=[assignment.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) == 2