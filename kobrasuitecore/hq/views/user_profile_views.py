# File: hq/views/user_profile_viewset.py
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from hq.models import UserProfile
from hq.serializers.user_profile_serializers import UserProfileSerializer

class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.select_related('user').all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        /users/<user_pk>/profile/<profile_pk>/
        """
        user_pk = self.kwargs.get('user_pk')
        return self.queryset.filter(user__id=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        user = get_object_or_404(get_user_model(), pk=user_pk)
        serializer.save(user=user)

    def perform_update(self, serializer):
        # Keep the existing user relationship
        instance = self.get_object()
        serializer.save(user=instance.user)