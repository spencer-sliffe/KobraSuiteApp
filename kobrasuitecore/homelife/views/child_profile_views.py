from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import ChildProfile
from homelife.serializers.child_profile_serializer import ChildProfileSerializer
from hq.models import HomeLifeProfile


class ChildProfileViewSet(viewsets.ModelViewSet):
    """
    Nested under homelife_profile_router:
    e.g. /.../homelife_profile/<homelife_profile_pk>/child_profiles/
    """
    serializer_class = ChildProfileSerializer

    def get_queryset(self):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        return ChildProfile.objects.filter(parent_profile_id=homelife_profile_id)

    def perform_create(self, serializer):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        parent_profile = get_object_or_404(HomeLifeProfile, pk=homelife_profile_id)
        serializer.save(parent_profile=parent_profile)