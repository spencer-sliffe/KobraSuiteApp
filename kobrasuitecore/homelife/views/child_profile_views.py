from rest_framework import viewsets, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from homelife.models import ChildProfile, Household           # ⬅ household import for safety‑check
from homelife.serializers.child_profile_serializer import ChildProfileSerializer
from hq.models import HomeLifeProfile


class ChildProfileViewSet(viewsets.ModelViewSet):
    """
    URL pattern (nested):
      /users/<user_pk>/profile/<user_profile_pk>/homelife_profile/
      <homelife_profile_pk>/households/<household_pk>/child_profiles/
    """
    serializer_class = ChildProfileSerializer

    # ---------- queries ----------
    def get_queryset(self):
        hl_pk = self.kwargs.get("homelife_profile_pk")
        hh_pk = self.kwargs.get("household_pk")

        # Ensure only children that belong to the target profile *and* household are returned
        return ChildProfile.objects.filter(
            parent_profile_id=hl_pk,
            parent_profile__household_id=hh_pk
        )

    # ---------- create ----------
    def perform_create(self, serializer):
        hl_pk = self.kwargs.get("homelife_profile_pk")
        hh_pk = self.kwargs.get("household_pk")

        parent_profile = get_object_or_404(HomeLifeProfile, pk=hl_pk)

        # Safety‑check: make sure the homelife_profile really belongs to the household in the URL
        if parent_profile.household_id != int(hh_pk):
            return Response(
                {"detail": "HomeLifeProfile does not belong to this household."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer.save(parent_profile=parent_profile)