# kobrasuitecore/asgi.py
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kobrasuitecore.settings')
django.setup()
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from school.middleware import JWTAuthMiddlewareStack
from school.routing import websocket_urlpatterns as school_websocket_urlpatterns

django_asgi_app = get_asgi_application()

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": JWTAuthMiddlewareStack(
        URLRouter(school_websocket_urlpatterns)
    ),
})