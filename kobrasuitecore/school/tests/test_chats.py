# school/tests/test_chats.py

import json
import pytest
import logging

from channels.auth import AuthMiddlewareStack
from channels.routing import URLRouter
from channels.testing import WebsocketCommunicator
from django.conf import settings
from rest_framework.test import APIClient

from customer.tests.factories import UserFactory
from kobrasuitecore.asgi import application  # Import the main ASGI application
from school.routing import websocket_urlpatterns
from rest_framework_simplejwt.backends import TokenBackend

logger = logging.getLogger(__name__)


@pytest.mark.asyncio
@pytest.mark.django_db
class TestSchoolChatConsumer:
    """
    async def test_send_chat_message(self, websocket_tokens, caplog):

        with caplog.at_level(logging.DEBUG):
            # Extract users and tokens
            user1_info = websocket_tokens['user1']
            user2_info = websocket_tokens['user2']

            # user1 belongs to university=999, user2 belongs to the same university=999
            # both have valid tokens
            token1 = user1_info['token']
            token2 = user2_info['token']

            # Send the "Bearer" token in the "authorization" header
            headers_user1 = [
                (b"authorization", f"Bearer {token1}".encode()),
            ]
            headers_user2 = [
                (b"authorization", f"Bearer {token2}".encode()),
            ]

            # Connect them to /ws/school-chat/UNIVERSITY/999/
            communicator1 = WebsocketCommunicator(
                application,  # your ProtocolTypeRouter(...) with JWTAuthMiddlewareStack
                "/ws/school-chat/UNIVERSITY/999/",
                headers=headers_user1
            )
            communicator2 = WebsocketCommunicator(
                application,
                "/ws/school-chat/UNIVERSITY/999/",
                headers=headers_user2
            )

            try:
                connected1, _ = await communicator1.connect()
                assert connected1 is True

                connected2, _ = await communicator2.connect()
                assert connected2 is True

                # Receive presence event
                presence_response = await communicator2.receive_json_from(timeout=3)
                assert presence_response["type"] == "presence"
                assert presence_response["status"] == "joined"
                assert presence_response["user"] == "user1"

                # Send and receive chat message
                msg = {"type": "message", "content": "Hello from user1!"}
                await communicator1.send_json_to(msg)

                response = await communicator2.receive_json_from(timeout=3)
                assert response["type"] == "message"
                assert response["user"] == "user1"
                assert response["content"] == "Hello from user1!"

            except Exception as e:
                pytest.fail(f"Test failed: {e}")
            finally:
                await communicator1.disconnect()
                await communicator2.disconnect()

            # Optionally, check logs for authentication details
            for record in caplog.records:
                logger.debug(f"Log Record: {record.levelname} - {record.message}")
"""
    async def test_connect_and_receive_presence(self):
        application = AuthMiddlewareStack(
            URLRouter(websocket_urlpatterns)
        )
        communicator = WebsocketCommunicator(application, "/ws/school-chat/COURSE/123/")
        connected, subprotocol = await communicator.connect()
        assert connected is True

        await communicator.disconnect()


@pytest.mark.django_db
class TestDiscussionEndpoints:
    def test_thread_scope_listing(self, authenticated_client, discussion_thread_factory):
        client, user = authenticated_client
        discussion_thread_factory(scope="COURSE", scope_id=10)
        discussion_thread_factory(scope="COURSE", scope_id=10)
        discussion_thread_factory(scope="COURSE", scope_id=99)

        url = "/api/discussion-threads/by_scope/?scope=COURSE&scope_id=10"
        response = client.get(url)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2

    def test_post_for_thread(self, authenticated_client, discussion_thread_factory, discussion_post_factory):
        client, user = authenticated_client
        thread = discussion_thread_factory()
        discussion_post_factory(thread=thread, content="First post")
        discussion_post_factory(thread=thread, content="Second post")

        url = f"/api/discussion-posts/for_thread/?thread_id={thread.id}"
        response = client.get(url)
        print(response.data)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2
        assert data[0]["content"] == "First post"
        assert data[1]["content"] == "Second post"