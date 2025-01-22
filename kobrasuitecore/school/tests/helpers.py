# school/tests/helpers.py

from rest_framework import status
from school.tests.factories import UniversityFactory


def get_authenticated_client(api_client, user, password="password123", login_url="/api/auth/login/"):
    user.password=password
    response = api_client.post(login_url, {"username": user.username, "password": password}, format='json')
    if response.status_code == status.HTTP_200_OK:
        token = response.data.get("access")
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    return api_client


def assert_error_response(response, expected_status_code, expected_message=None):
    assert response.status_code == expected_status_code, (
        f"Expected status {expected_status_code}, got {response.status_code}. Response: {response.data}"
    )
    if expected_message:
        assert expected_message.lower() in str(response.data).lower(), (
            f"Expected message '{expected_message}' in response {response.data}"
        )


def create_school_profile_for_user(user, university_factory=None):
    from customer.models import SchoolProfile
    school_profile, created = SchoolProfile.objects.get_or_create(user=user)
    if university_factory:
        uni = UniversityFactory()
        school_profile.university = uni
        school_profile.save()
    return school_profile