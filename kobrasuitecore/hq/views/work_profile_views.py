# File: hq/views/work_profile_viewset.py
from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from hq.models import UserProfile, WorkProfile
from hq.serializers.work_profile_serializers import WorkProfileSerializer

class WorkProfileViewSet(viewsets.ModelViewSet):
    queryset = WorkProfile.objects.select_related('profile__user').all()
    serializer_class = WorkProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Nested route:
        /users/<user_pk>/profile/<profile_pk>/work_profile/<work_profile_pk>/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        return self.queryset.filter(
            profile__id=profile_pk,
            profile__user__id=user_pk
        )

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        user_profile = get_object_or_404(UserProfile, pk=profile_pk, user__id=user_pk)
        serializer.save(profile=user_profile)

    def perform_update(self, serializer):
        instance = self.get_object()
        serializer.save(profile=instance.profile)