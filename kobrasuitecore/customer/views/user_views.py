# customer/chatgpt_views.py
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.contrib.auth import get_user_model

from customer.models import Role
from customer.permissions import IsOwnerOrAdmin
from customer.serializers.user_serializers import UserSerializer, RoleSerializer

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.is_staff:
            return User.objects.all()
        return User.objects.filter(id=user.id)


class RoleViewSet(viewsets.ModelViewSet):
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]
