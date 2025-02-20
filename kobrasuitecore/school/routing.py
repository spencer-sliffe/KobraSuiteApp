"""
------------------Prologue--------------------
File Name: routing.py
Path: kobrasuitecore/school/routing.py

Description:
Defines WebSocket URL routing patterns for the school chat functionality.
Maps URL patterns with scope types and scope IDs to the SchoolChatConsumer for real-time communication.

Input:
WebSocket connection requests with specific scope_type and scope_id parameters.

Output:
WebSocket connections routed to the appropriate consumer for handling school chat operations.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.urls import re_path
from .consumers import SchoolChatConsumer

ALLOWED_SCOPE_TYPES = ['UNIVERSITY', 'COURSE', 'ASSIGNMENT']
scope_regex = '|'.join(ALLOWED_SCOPE_TYPES)

websocket_urlpatterns = [
    re_path(
        rf'^ws/school-chat/(?P<scope_type>{scope_regex})/(?P<scope_id>\d+)/$',
        SchoolChatConsumer.as_asgi(),
        name='school_chat'
    ),
]