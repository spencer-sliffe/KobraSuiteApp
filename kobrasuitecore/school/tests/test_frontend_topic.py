# tests/test_frontend_topic.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import TopicFactory, CourseFactory
from .helpers import get_authenticated_client

@pytest.mark.django_db
class TestFrontEndTopicSlug:
    def test_topic_details_include_course_code(self, authenticated_client, topic_factory):
        client, user = authenticated_client
        topic = topic_factory()
        url = reverse('topics-detail', args=[topic.id])
        response = client.get(url)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["course"]["course_code"] is not None
        assert data["name"] == topic.name

    def test_topic_study_documents(
        self, authenticated_client, topic_factory, study_document_factory
    ):
        client, user = authenticated_client
        topic = topic_factory()
        d1 = study_document_factory(topic=topic, author_id=user.id, title="Doc1")
        d2 = study_document_factory(topic=topic, author_id=user.id, title="Doc2")
        url = reverse('studydocuments-list')
        response = client.get(url, {"topic": topic.id})
        assert response.status_code == status.HTTP_200_OK
        data = response.json().get("results", response.json())
        titles = [doc["title"] for doc in data]
        assert "Doc1" in titles
        assert "Doc2" in titles

    def test_upload_study_document_button(self, authenticated_client, topic_factory):
        client, user = authenticated_client
        topic = topic_factory()
        payload = {"topic_id": topic.id, "title": "New Doc"}
        url = reverse('studydocuments-list')
        response = client.post(url, payload, format='json')
        assert response.status_code == status.HTTP_201_CREATED