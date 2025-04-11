# File: hq/views/homelife_profile_viewset.py
from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from customer.permissions import IsOwnerOrAdmin
from hq.models import HomeLifeProfile, UserProfile  # Assuming UserProfile is defined in hq.models
from hq.serializers.homelife_profile_serializers import HomeLifeProfileSerializer


class HomeLifeProfileViewSet(viewsets.ModelViewSet):
    queryset = HomeLifeProfile.objects.select_related('profile__user', 'household')
    serializer_class = HomeLifeProfileSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/user_profile/<user_profile_pk>/homelife_profile/
        """
        user_pk = self.kwargs.get('user_pk')
        user_profile_pk = self.kwargs.get('user_profile_pk')
        return self.queryset.filter(
            profile__user_id=user_pk,
            profile_id=user_profile_pk
        )

    def perform_create(self, serializer):
        """
        Retrieves the UserProfile via the nested URL parameter and saves the
        HomeLifeProfile with the correct profile instance.
        """
        user_profile_pk = self.kwargs.get('user_profile_pk')
        user_profile = get_object_or_404(UserProfile, pk=user_profile_pk)
        serializer.save(profile=user_profile)

    def perform_update(self, serializer):
        """
        Ensures that the profile association remains unchanged during updates.
        """
        serializer.save(profile=self.get_object().profile)