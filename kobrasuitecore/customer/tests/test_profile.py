# customer/tests/test_profile.py

import pytest
from django.urls import reverse
from rest_framework import status
from customer.tests.factories import UserFactory
from school.tests.factories import UniversityFactory
from customer.models import UserProfile
from .helpers import get_authenticated_client


@pytest.mark.django_db
class TestUserProfile:
    def test_add_university_to_profile_authenticated_user(self):
        client, user = get_authenticated_client()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university.id
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200 OK, got {response.status_code}. Response: {response.data}"
        )
        assert response.data['school_profile']['university'] == university.id, (
            f"Expected university ID to be {university.id}, got {response.data['school_profile']['university']}."
        )
        user.refresh_from_db()
        assert user.school_profile.university == university, (
            "University was not correctly associated in the database."
        )

    def test_update_university_in_profile_authenticated_user(self):
        client, user = get_authenticated_client()
        university1 = UniversityFactory()
        university2 = UniversityFactory()
        user.profile.university = university1
        user.profile.save()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university2.id
            }
        }
        response = client.patch(url, payload, format='json')

        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200 OK, got {response.status_code}. Response: {response.data}"
        )
        assert response.data['school_profile']['university'] == university2.id, (
            f"Expected university ID to be {university2.id}, got {response.data['school_profile']['university']}."
        )
        user.refresh_from_db()
        assert user.school_profile.university == university2, (
            "University was not correctly updated in the database."
        )

    def test_add_university_to_profile_unauthenticated_user(self, api_client):
        user = UserFactory()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university.id
            }
        }
        response = api_client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED, (
            f"Expected 401 Unauthorized, got {response.status_code}. Response: {response.data}"
        )
        assert "Authentication credentials were not provided." in str(response.data), (
            "Expected authentication error message."
        )
        user.refresh_from_db()
        assert user.school_profile.university is None, (
            "University should not be set for unauthenticated user."
        )

    def test_add_nonexistent_university_to_profile(self):
        client, user = get_authenticated_client()
        nonexistent_university_id = 9999
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": nonexistent_university_id
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST, (
            f"Expected 400 Bad Request, got {response.status_code}. Response: {response.data}"
        )
        assert "university" in response.data['school_profile'], (
            "Expected 'university' field error in response."
        )
        user.refresh_from_db()
        assert user.school_profile.university is None, (
            "University should not be set when invalid ID is provided."
        )

    def test_add_university_to_profile_missing_profile_field(self):
        client, user = get_authenticated_client()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "username": "newusername"
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200 OK, got {response.status_code}. Response: {response.data}"
        )
        user.refresh_from_db()
        assert user.school_profile.university is None, (
            "University should remain unchanged when 'profile' is not provided."
        )
        assert user.username == "newusername", (
            "Username should be updated even when 'profile' is not provided."
        )

    def test_add_university_with_partial_profile_data(self):
        client, user = get_authenticated_client()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university.id,
            },
            "profile": {
                "address": "4567 Oak Avenue",
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200 OK, got {response.status_code}. Response: {response.data}"
        )
        assert response.data['school_profile']['university'] == university.id, (
            f"Expected university ID to be {university.id}, got {response.data['school_profile']['university']}."
        )
        assert response.data['profile']['address'] == "4567 Oak Avenue", (
            f"Expected address to be '4567 Oak Avenue', got '{response.data['profile']['address']}'."
        )
        user.refresh_from_db()
        assert user.school_profile.university == university, (
            "University was not correctly associated in the database."
        )
        assert user.profile.address == "4567 Oak Avenue", (
            "Address was not correctly updated in the database."
        )

    def test_add_university_to_profile_without_existing_userprofile(self):
        client, user = get_authenticated_client()
        UserProfile.objects.filter(user=user).delete()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university.id
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_200_OK, (
            f"Expected 200 OK, got {response.status_code}. Response: {response.data}"
        )
        assert response.data['school_profile']['university'] == university.id, (
            f"Expected university ID to be {university.id}, got {response.data['school_profile']['university']}."
        )
        user.refresh_from_db()
        assert user.school_profile.university == university, (
            "University was not correctly associated in the database."
        )

    def test_add_university_to_profile_invalid_request_method(self):
        client, user = get_authenticated_client()
        university = UniversityFactory()
        url = reverse('users-detail', args=[user.id])
        payload = {
            "school_profile": {
                "university": university.id
            }
        }
        response = client.post(url, payload, format='json')
        assert response.status_code == status.HTTP_405_METHOD_NOT_ALLOWED, (
            f"Expected 405 Method Not Allowed, got {response.status_code}. Response: {response.data}"
        )
        assert 'method "post" not allowed' in response.data['detail'].lower(), (
            "Expected 'method not allowed' message."
        )
        user.refresh_from_db()
        assert user.school_profile.university is None, (
            "University should not be set when using an incorrect HTTP method."
        )

    def test_add_university_to_other_user_profile(self):
        client, user = get_authenticated_client()
        other_user = UserFactory()
        university = UniversityFactory()
        url = reverse('users-detail', args=[other_user.id])
        payload = {
            "school_profile": {
                "university": university.id
            }
        }
        response = client.patch(url, payload, format='json')
        assert response.status_code == status.HTTP_404_NOT_FOUND, (
            f"Expected 404 Not Found, got {response.status_code}. Response: {response.data}"
        )
        other_user.refresh_from_db()
        assert other_user.school_profile.university is None, (
            "University should not be set for another user's profile."
        )