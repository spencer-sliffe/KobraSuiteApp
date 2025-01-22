# tests/test_submission.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import SubmissionFactory, AssignmentFactory
from customer.tests.factories import UserFactory
from .helpers import get_authenticated_client
from django.core.files.uploadedfile import SimpleUploadedFile


@pytest.mark.django_db
class TestSubmissionEndpoints:
    def test_create_submission(self, api_client):
        user = UserFactory()
        assignment = AssignmentFactory()
        client = get_authenticated_client(api_client, user)
        url = reverse('submissions-list')
        payload = {
            "assignment_id": assignment.id,
            "text_answer": "Here is my essay..."
        }
        response = client.post(url, payload, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["student"] == user.id

    def test_upload_answer_file(self, api_client):
        submission = SubmissionFactory()
        user = submission.student
        client = get_authenticated_client(api_client, user)

        url = reverse('submissions-upload-answer', args=[submission.id])
        file_data = SimpleUploadedFile("answer.txt", b"Hello World", content_type="text/plain")
        response = client.post(url, {"answer_file": file_data}, format='multipart')
        assert response.status_code == status.HTTP_200_OK
        submission.refresh_from_db()
        assert submission.answer_file.name is not None

    def test_list_submissions_unauthenticated(self, api_client):
        url = reverse('submissions-list')
        response = api_client.get(url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_retrieve_submission(self, authenticated_client, submission_factory):
        client, user = authenticated_client
        sub = submission_factory(student=user)
        url = reverse('submissions-detail', args=[sub.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == sub.id
        assert data["student"] == user.id