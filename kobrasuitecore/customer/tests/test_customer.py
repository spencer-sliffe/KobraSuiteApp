# test_customer.py

import pytest
from django.urls import reverse
from rest_framework import status
from customer.tests.factories import UserFactory, RoleFactory
from customer.models import Role
from .helpers import get_authenticated_client


@pytest.mark.django_db
class TestCustomer:

    def test_role_creation(self):
        role = RoleFactory()
        assert Role.objects.count() == 1
        assert role.name is not None

    def test_user_has_role(self):
        user = UserFactory()
        role = RoleFactory()
        role.users.add(user)
        role.save()
        assert user.has_role(role.name) is True

    def test_update_user_profile(self):
        client, user = get_authenticated_client()
        url = reverse('users-detail', args=[user.id])

        payload = {
            "profile": {
                "address": "1234 Elm St.",
                "preferences": {"color_scheme": "dark"}
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['profile']['address'] == "1234 Elm St."
        assert response.data['profile']['preferences']['color_scheme'] == "dark"

    def test_update_user_profile_unauthenticated(self, api_client):
        user = UserFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "profile": {
                "address": "1111 Cherry Lane"
            }
        }
        response = api_client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED