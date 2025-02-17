"""
------------------Prologue--------------------
File Name: consumers.py
Path: kobrasuitecore/school/consumers.py

Description:
Defines a WebSocket consumer for the school chat functionality.
Manages connection lifecycle events, message handling, heartbeat monitoring, and presence notifications.
Saves discussion posts to the database as part of the chat interactions.

Input:
WebSocket messages of various types (message, heartbeat, typing, ping) from connected clients.

Output:
Real-time chat broadcasts, presence updates, and acknowledgment responses to connected users.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
import json
import logging
import asyncio
import bleach
from datetime import datetime

from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from school.models import DiscussionThread, DiscussionPost

logger = logging.getLogger(__name__)


class SchoolChatConsumer(AsyncWebsocketConsumer):
    HEARTBEAT_INTERVAL = 20
    HEARTBEAT_TIMEOUT = 40

    async def connect(self):
        self.scope_type = self.scope['url_route']['kwargs']['scope_type']
        self.scope_id = self.scope['url_route']['kwargs']['scope_id']
        self.room_group_name = f"{self.scope_type}-{self.scope_id}"
        self.last_heartbeat = datetime.utcnow()

        allowed_scopes = ['UNIVERSITY', 'COURSE', 'ASSIGNMENT']
        if self.scope_type not in allowed_scopes:
            logger.warning(f"Connection rejected: Invalid scope_type: {self.scope_type}")
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

        user_display = self.scope['user'].username if self.scope['user'].is_authenticated else 'Anonymous'
        logger.info(f"User '{user_display}' connected to group '{self.room_group_name}'")
        await self.send_presence(status="joined", user=user_display)

        self.heartbeat_task = asyncio.create_task(self._heartbeat_loop())

    async def disconnect(self, close_code):
        user_display = self.scope['user'].username if self.scope['user'].is_authenticated else 'Anonymous'
        if hasattr(self, 'heartbeat_task'):
            self.heartbeat_task.cancel()
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)
        await self.send_presence(status="left", user=user_display)
        logger.info(f"User '{user_display}' disconnected from group '{self.room_group_name}' with code {close_code}")

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data:
            return

        try:
            data = json.loads(text_data)
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON received: {e}")
            return

        msg_type = data.get("type")
        if msg_type == "message":
            payload = data.get("payload", {})
            content = payload.get("content", "").strip()
            if content:
                safe_content = bleach.clean(content)
                await self.handle_chat_message(safe_content)
        elif msg_type == "heartbeat":
            self.last_heartbeat = datetime.now()
            logger.debug(f"Heartbeat received from {self.scope['user'].username} at {self.last_heartbeat.isoformat()}")
            await self.send(text_data=json.dumps({"type": "heartbeat", "timestamp": self._current_timestamp()}))
        elif msg_type == "typing":
            user_display = self.scope['user'].username if self.scope['user'].is_authenticated else 'Anonymous'
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat.typing',
                    'user': user_display,
                    'timestamp': data.get('timestamp'),
                }
            )
        elif msg_type == "ping":
            await self.send(text_data=json.dumps({"type": "pong", "timestamp": self._current_timestamp()}))
        else:
            logger.debug(f"Unhandled message type: {msg_type}")

    async def _heartbeat_loop(self):
        try:
            while True:
                await asyncio.sleep(self.HEARTBEAT_INTERVAL)
                elapsed = (datetime.utcnow() - self.last_heartbeat).total_seconds()
                if elapsed > self.HEARTBEAT_TIMEOUT:
                    logger.warning(f"Client inactive for {elapsed} seconds, closing connection: {self.scope['user'].username}")
                    await self.close(code=4001)
                    break
        except asyncio.CancelledError:
            logger.debug("Heartbeat loop cancelled.")

    async def send_presence(self, status, user):
        payload = {
            "type": "presence",
            "status": status,
            "user": user,
            "timestamp": self._current_timestamp()
        }
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat.presence',
                **payload
            }
        )
        logger.info(f"Presence event sent: {payload}")

    async def chat_presence(self, event):
        await self.send(text_data=json.dumps({
            "type": "presence",
            "status": event.get("status"),
            "user": event.get("user"),
            "timestamp": event.get("timestamp")
        }))

    async def chat_typing(self, event):
        await self.send(text_data=json.dumps({
            "type": "typing",
            "user": event.get('user'),
            "timestamp": event.get('timestamp')
        }))

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            "type": "message",
            "user": event.get('username'),
            "content": event.get('content'),
            "timestamp": self._current_timestamp()
        }))

    async def handle_chat_message(self, safe_content: str):
        user = self.scope['user']
        if not user.is_authenticated:
            logger.warning("Unauthenticated user attempted to send a message.")
            return

        post_id = await self.save_discussion_post(safe_content)
        logger.info(f"Message saved with post_id: {post_id} by {user.username}")

        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat.message',
                'username': user.username,
                'content': safe_content,
            }
        )

    def _current_timestamp(self):
        return datetime.now().isoformat() + 'Z'

    @database_sync_to_async
    def save_discussion_post(self, content: str) -> int:
        from django.contrib.contenttypes.models import ContentType
        try:
            thread = DiscussionThread.objects.get(
                scope_content_type__model=self.scope_type.lower(),
                scope_object_id=self.scope_id
            )
        except DiscussionThread.DoesNotExist:
            content_type = ContentType.objects.get(model=self.scope_type.lower())
            thread = DiscussionThread.objects.create(
                scope_content_type=content_type,
                scope_object_id=self.scope_id,
                title=f"Autogenerated thread: {self.scope_type}-{self.scope_id}",
                created_by=self.scope['user']
            )
            logger.info(f"Created new thread: {thread.title}")
        post = DiscussionPost.objects.create(
            thread=thread,
            author=self.scope['user'],
            content=content
        )
        return post.id