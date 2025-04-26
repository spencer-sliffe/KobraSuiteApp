from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

from homelife.models import HouseholdInvite, Household
from homelife.serializers.household_invite_serializer import HouseholdInviteSerializer
from hq.models import HomeLifeProfile


class HouseholdInviteViewSet(viewsets.ModelViewSet):
    """
    Nested under /households/<household_pk>/household_invites/
    """
    serializer_class = HouseholdInviteSerializer

    # ---------- CRUD --------------------------------------------------
    def get_queryset(self):
        return HouseholdInvite.objects.filter(
            household_id=self.kwargs['household_pk']
        )

    def perform_create(self, serializer):
        household = get_object_or_404(Household, pk=self.kwargs['household_pk'])
        serializer.save(household=household)

    # ---------- JOIN / REDEEM ----------------------------------------
    @action(detail=False, methods=['post'], url_path='redeem', url_name='redeem_invite')
    def redeem(self, request, *args, **kwargs):
        code = request.data.get('code', '').strip()
        profile_id = kwargs.get('homelife_profile_pk')

        if not code:
            return Response({'detail': 'Code required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        invite = HouseholdInvite.objects.filter(code=code).first()
        if not invite:
            return Response({'detail': 'Invalid code.'},
                            status=status.HTTP_404_NOT_FOUND)

        profile = get_object_or_404(HomeLifeProfile, pk=profile_id)
        profile.household = invite.household
        profile.save()

        # one-time use → delete
        invite.delete()
        return Response({'household_id': profile.household_id},
                        status=status.HTTP_200_OK)