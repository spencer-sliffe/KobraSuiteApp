# File: hq/views/finance_profile_viewset.py
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from hq.models import UserProfile, FinanceProfile
from hq.serializers.finance_profile_serializers import FinanceProfileSerializer

class FinanceProfileViewSet(viewsets.ModelViewSet):
    queryset = FinanceProfile.objects.select_related('profile__user').all()
    serializer_class = FinanceProfileSerializer
    permission_classes = [IsAuthenticated]


    def get_queryset(self):
        """
        Nested route:
        /users/<user_pk>/profile/<profile_pk>/finance_profile/<finance_profile_pk>/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        return self.queryset.filter(
            profile__id=profile_pk,
            profile__user__id=user_pk
        )

    def perform_create(self, serializer):
        """
        Ties the FinanceProfile to the correct UserProfile,
        identified by user_pk + profile_pk.
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        user_profile = get_object_or_404(UserProfile, pk=profile_pk, user__id=user_pk)
        serializer.save(profile=user_profile)

    def perform_update(self, serializer):
        """
        On update, preserve the existing .profile rather than replacing it.
        """
        instance = self.get_object()
        serializer.save(profile=instance.profile)