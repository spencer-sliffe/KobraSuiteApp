"""
------------------Prologue--------------------
File Name: user_views.py
Path: kobrasuitecore/customer/user_views.py

Description:
Implements CRUD operations for user accounts with access restrictions, ensuring only admins
or the respective users can view or modify their data.

Input:
Requests to retrieve or modify user profiles.

Output:
User data in JSON format or success/error responses for each operation.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# File: customer/user_views.py
from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from customer.permissions import IsOwnerOrAdmin
from customer.serializers.user_serializers import UserSerializer
from customer.models import Role

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.select_related(
        'profile'
    ).all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.is_staff:
            return self.queryset
        return self.queryset.filter(id=user.id)
