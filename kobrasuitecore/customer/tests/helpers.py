# customer/helpers.py

from rest_framework.test import APIClient
from django.urls import reverse
from rest_framework import status


def get_authenticated_client(user=None, is_staff=False, is_superuser=False):
    from customer.tests.factories import UserFactory

    if not user:
        user = UserFactory(is_staff=is_staff, is_superuser=is_superuser)
        user.set_password('password123')
        user.save()
    client = APIClient()
    login_url = reverse('auth-login')
    response = client.post(login_url, {
        'username': user.username,
        'password': 'password123'
    }, format='json')
    if response.status_code == status.HTTP_200_OK:
        access = response.data.get('access')
        client.credentials(HTTP_AUTHORIZATION='Bearer ' + access)
    return client, user