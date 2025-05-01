import pytest
from django.urls import reverse
from customer.tests.factories import UserFactory
from rest_framework import status


@pytest.mark.django_db
class TestAuthEndpoints:

    def test_register_success(self, api_client):
        url = reverse('auth-register')
        data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "P@ssw0rd123",
            "confirm_password": "P@ssw0rd123"
        }
        response = api_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['success'] is True
        assert 'user' in response.data
        assert response.data['user']['username'] == "testuser"
        assert 'access' in response.data
        assert 'refresh' in response.data

    def test_register_password_mismatch(self, api_client):
        url = reverse('auth-register')
        data = {
            "username": "testuser2",
            "email": "test2@example.com",
            "password": "P@ssw0rd123",
            "confirm_password": "WrongPassword"
        }
        response = api_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert response.data['success'] is False
        assert "Passwords do not match" in str(response.data)

    def test_login_success(self, api_client):
        user = UserFactory(username="loginuser", email="login@example.com")
        user.set_password("password123")
        user.save()
        url = reverse('auth-login')
        data = {
            "username": "loginuser",
            "password": "password123"
        }
        response = api_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['success'] is True
        assert response.data['user']['username'] == "loginuser"
        assert 'access' in response.data
        assert 'refresh' in response.data

    def test_login_invalid_credentials(self, api_client):
        url = reverse('auth-login')
        data = {
            "username": "nonexistent",
            "password": "invalidpass"
        }
        response = api_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        assert response.data['success'] is False
        assert "Invalid credentials" in str(response.data)

    def test_logout(self, api_client):
        user = UserFactory()
        login_url = reverse('auth-login')
        login_data = {
            "username": user.username,
            "password": "password123"
        }
        response = api_client.post(login_url, login_data, format='json')
        access = response.data.get('access')
        refresh = response.data.get('refresh')
        api_client.credentials(HTTP_AUTHORIZATION='Bearer ' + access)
        url = reverse('auth-logout')
        response = api_client.post(url, {"refresh": refresh}, format='json')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['success'] is True

    def test_whoami_authenticated(self, api_client):
        user = UserFactory()
        user.set_password("password123")
        user.save()
        login_url = reverse('auth-login')
        login_data = {
            "username": user.username,
            "password": "password123"
        }
        response = api_client.post(login_url, login_data, format='json')
        access = response.data.get('access')
        api_client.credentials(HTTP_AUTHORIZATION='Bearer ' + access)
        url = reverse('auth-whoami')
        response = api_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['user']['email'] == user.email

    def test_whoami_unauthenticated(self, api_client):
        url = reverse('auth-whoami')
        response = api_client.get(url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        assert "Authentication credentials were not provided." in str(response.data)