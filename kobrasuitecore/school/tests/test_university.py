# tests/test_University.py

import pytest
from django.urls import reverse
from rest_framework import status
from .factories import UniversityFactory
from customer.tests.factories import UserFactory, SchoolProfileFactory
from .helpers import get_authenticated_client
from customer.tests.factories import UserFactory


@pytest.mark.django_db
class TestUniversityEndpoints:
    def test_list_universities_success(self, authenticated_client, university_factory):
        university_factory.create_batch(3)
        user = UserFactory()
        url = reverse('university-list')  # e.g. /api/school/university/
        client, user = authenticated_client
        response = client.get(url)
        print(response.data)
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200, got {response.status_code}."
        )
        assert response.data["count"] == 3

    def test_retrieve_university(self, authenticated_client, university_factory):
        uni = university_factory()
        url = reverse('university-detail', args=[uni.id])
        client, user = authenticated_client
        response = client.get(url)
        print(response.data)
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200, got {response.status_code}."
        )
        assert response.data['id'] == uni.id

    def test_search_universities(self, authenticated_client):
        client, user = authenticated_client
        url = reverse('university-search-universities')
        response = client.get(url, {"name": "TestU"})
        assert response.status_code in [status.HTTP_200_OK]