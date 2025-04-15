from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import Household
from homelife.serializers.household_serializer import HouseholdSerializer
from hq.models import HomeLifeProfile


class HouseholdViewSet(viewsets.ModelViewSet):
    """
    Nested under homelife_profile_router:
    e.g. /.../homelife_profile/<homelife_profile_pk>/households/
    """
    serializer_class = HouseholdSerializer

    def get_queryset(self):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        return Household.objects.all()

    def perform_create(self, serializer):
        # If you link a newly created Household to the homelife_profile in some manner:
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        homelife_profile = get_object_or_404(HomeLifeProfile, pk=homelife_profile_id)
        # Insert any logic that sets fields, e.g. homelife_profile=...
        # If not needed, you can skip it entirely
        serializer.save()