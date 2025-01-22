import pytest
from rest_framework.test import APIClient

@pytest.fixture
def api_client():
    """
    Provides an unauthenticated APIClient for tests.
    """
    return APIClient()
