# homelife/views/household_views.py

from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import Household
from homelife.serializers.household_serializer import HouseholdSerializer
from hq.models import HomeLifeProfile


class HouseholdViewSet(viewsets.ModelViewSet):
    serializer_class = HouseholdSerializer

    def get_queryset(self):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        return Household.objects.filter(homelife_profiles__pk=homelife_profile_id)

    def perform_create(self, serializer):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        homelife_profile = get_object_or_404(HomeLifeProfile, pk=homelife_profile_id)
        household = serializer.save()
        # link it back to the HomeLifeProfile
        homelife_profile.household = household
        homelife_profile.save()