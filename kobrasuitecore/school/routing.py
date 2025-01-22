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