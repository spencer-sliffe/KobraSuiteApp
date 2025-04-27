# homelife/views/household_views.py

from rest_framework import viewsets, mixins
from django.shortcuts import get_object_or_404
from rest_framework.generics import ListAPIView

from homelife.models import Household
from homelife.serializers.household_serializer import HouseholdSerializer
from hq.models import HomeLifeProfile
from hq.serializers.homelife_profile_serializers import HomeLifeProfileSerializer


class HouseholdViewSet(viewsets.ModelViewSet):
    serializer_class = HouseholdSerializer

    def get_queryset(self):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        return Household.objects.filter(homelife_profiles__pk=homelife_profile_id)

    def perform_create(self, serializer):
        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        homelife_profile = get_object_or_404(HomeLifeProfile, pk=homelife_profile_id)
        # hard-fail if the code is already taken
        household = serializer.save()
        homelife_profile.household = household
        homelife_profile.save()


class HouseholdMemberViewSet(mixins.ListModelMixin,
                             viewsets.GenericViewSet):
    serializer_class = HomeLifeProfileSerializer

    def get_queryset(self):
        return HomeLifeProfile.objects.filter(
            household_id=self.kwargs["household_pk"]
        )
