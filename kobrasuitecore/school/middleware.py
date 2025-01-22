# school/tests/middleware.py

import logging
from channels.middleware import BaseMiddleware
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.backends import TokenBackend
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.contrib.auth import get_user_model
from channels.db import database_sync_to_async
from django.conf import settings
from urllib.parse import parse_qs

logger = logging.getLogger(__name__)
User = get_user_model()


@database_sync_to_async
def get_user_from_token(token):
    try:
        token_backend = TokenBackend(algorithm='HS256', signing_key=settings.SECRET_KEY)
        decoded_token = token_backend.decode(token, verify=True)
        user_id = decoded_token.get('user_id')
        logger.debug(f"Decoded token: {decoded_token}")
        user = User.objects.get(id=user_id)
        logger.debug(f"Authenticated user: {user.username}")
        return user
    except (InvalidToken, TokenError, User.DoesNotExist) as e:
        logger.warning(f"JWT Authentication failed: {e}")
        return AnonymousUser()


class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        headers = dict(scope.get('headers', {}))
        auth_header = headers.get(b'authorization', b'').decode()
        logger.debug(f"Authorization Header: {auth_header}")

        token = None

        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
            logger.debug(f"Received token from header: {token}")
        else:
            query_string = scope.get("query_string", b"").decode()
            query_params = parse_qs(query_string)
            token_list = query_params.get("token")
            if token_list:
                token = token_list[0]
                logger.debug(f"Received token from query parameters: {token}")
            else:
                logger.debug("No valid Authorization header or query token found.")

        if token:
            user = await get_user_from_token(token)
            scope['user'] = user
            if isinstance(user, AnonymousUser):
                logger.debug("User set as Anonymous due to failed authentication.")
            else:
                logger.debug(f"Authenticated user: {user.username}")
        else:
            scope['user'] = AnonymousUser()
            logger.debug("No token provided. User set as Anonymous.")

        return await super().__call__(scope, receive, send)


def JWTAuthMiddlewareStack(inner):
    return JWTAuthMiddleware(inner)