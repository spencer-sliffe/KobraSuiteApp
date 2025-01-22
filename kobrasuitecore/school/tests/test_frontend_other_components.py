# tests/test_frontend_other_components.py

import pytest
from django.urls import reverse
from rest_framework import status
from django.core.files.uploadedfile import SimpleUploadedFile


@pytest.mark.django_db
class TestFrontEndOtherComponents:
    def test_document_viewer(self, authenticated_client, study_document_factory):
        client, user = authenticated_client
        doc = study_document_factory(author=user)
        url = reverse('studydocuments-detail', args=[doc.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "file" in data

    def test_document_uploader_studydoc(self, authenticated_client, topic_factory):
        client, user = authenticated_client
        topic = topic_factory()
        url = reverse('studydocuments-list')
        file_data = SimpleUploadedFile("notes.pdf", b"PDF content", content_type="application/pdf")
        payload = {
            "topic_id": topic.id,
            "title": "My PDF Notes",
            "file": file_data
        }
        response = client.post(url, payload, format='multipart')
        assert response.status_code == status.HTTP_201_CREATED
        assert "id" in response.json()

    def test_document_uploader_submission(self, authenticated_client, assignment_factory):
        client, user = authenticated_client
        assignment = assignment_factory()
        sub_url = reverse('submissions-list')
        payload = {
            "assignment_id": assignment.id,
            "text_answer": "My text answer"
        }
        sub_resp = client.post(sub_url, payload, format='json')
        assert sub_resp.status_code == status.HTTP_201_CREATED
        sub_id = sub_resp.json()["id"]
        upload_url = reverse('submissions-upload-answer', args=[sub_id])
        file_data = SimpleUploadedFile("solution.docx", b"Word content", content_type="application/vnd.openxmlformats")
        upload_resp = client.post(upload_url, {"answer_file": file_data}, format='multipart')
        assert upload_resp.status_code == status.HTTP_200_OK