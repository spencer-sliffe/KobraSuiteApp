from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import HouseholdInvite, Household
from homelife.serializers.household_invite_serializer import HouseholdInviteSerializer
from hq.models import HomeLifeProfile


class HouseholdInviteViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/household_invites/
    """
    serializer_class = HouseholdInviteSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return HouseholdInvite.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)

        homelife_profile_id = self.kwargs.get('homelife_profile_pk')
        inviter_profile = get_object_or_404(HomeLifeProfile, pk=homelife_profile_id)

        serializer.save(inviter=inviter_profile, household=household)