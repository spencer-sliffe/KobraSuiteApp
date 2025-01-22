# school/tests/conftest.py
import pytest
from rest_framework.test import APIClient

from school.tests.factories import (
    UniversityFactory, CourseFactory, TopicFactory,
    AssignmentFactory, SubmissionFactory, StudyDocumentFactory,
    DiscussionThreadFactory, DiscussionPostFactory
)
from customer.tests.factories import UserFactory, SchoolProfileFactory


@pytest.fixture
def discussion_thread_factory():
    return DiscussionThreadFactory


@pytest.fixture
def discussion_post_factory():
    return DiscussionPostFactory


@pytest.fixture
def user_factory():
    return UserFactory


@pytest.fixture
def university_factory():
    return UniversityFactory


@pytest.fixture
def course_factory():
    return CourseFactory


@pytest.fixture
def assignment_factory():
    return AssignmentFactory


@pytest.fixture
def submission_factory():
    return SubmissionFactory


@pytest.fixture
def topic_factory():
    return TopicFactory


@pytest.fixture
def study_document_factory():
    return StudyDocumentFactory


@pytest.fixture
def school_profile_factory():
    return SchoolProfileFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def authenticated_client(api_client, user_factory):
    user = user_factory(username='testuser', email='test@example.com')
    user.set_password('password123')
    user.save()

    login_url = '/api/auth/login/'
    response = api_client.post(
        login_url,
        {"username": user.username, "password": "password123"},
        format='json'
    )
    if response.status_code == 200:
        token = response.data['access']
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    return api_client, user
