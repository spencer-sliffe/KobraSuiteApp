# File: customer/user_views.py
from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from customer.permissions import IsOwnerOrAdmin
from customer.serializers.user_serializers import UserSerializer
from customer.models import Role

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.select_related(
        'profile', 'school_profile', 'work_profile', 'finance_profile', 'homelife_profile'
    ).all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.is_staff:
            return self.queryset
        return self.queryset.filter(id=user.id)
