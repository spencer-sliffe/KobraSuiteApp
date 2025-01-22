# tests/test_frontend_assignment.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import AssignmentFactory, SubmissionFactory, CourseFactory
from .helpers import get_authenticated_client
from customer.tests.factories import UserFactory

@pytest.mark.django_db
class TestFrontEndAssignmentSlug:
    def test_assignment_details(
        self, authenticated_client, assignment_factory
    ):
        client, user = authenticated_client
        assignment = assignment_factory(title="Reading Report", course__course_code="HIST210")
        url = reverse('assignments-detail', args=[assignment.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["course"]["course_code"] == "HIST210"
        assert data["title"] == "Reading Report"
        assert "due_date" in data

    def test_display_assignment_answers(
        self, authenticated_client, assignment_factory, submission_factory
    ):
        client, user = authenticated_client
        assignment = assignment_factory()
        sub1 = submission_factory(assignment=assignment, text_answer="Answer 1")
        sub2 = submission_factory(assignment=assignment, text_answer="Answer 2")

        url = reverse('assignments-list-submissions', args=[assignment.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        answers = [s["text_answer"] for s in data]
        assert "Answer 1" in answers
        assert "Answer 2" in answers

    def test_submit_answer_button(self, authenticated_client, assignment_factory):
        client, user = authenticated_client
        assignment = assignment_factory()
        sub_url = reverse('submissions-list')
        payload = {
            "assignment_id": assignment.id,
            "text_answer": "My final essay"
        }
        response = client.post(sub_url, payload, format='json')
        assert response.status_code == status.HTTP_201_CREATED

    def test_open_assignment_chat_button(self):
        pass