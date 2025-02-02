from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from customer.permissions import IsOwnerOrAdmin
from hq.models import FinanceProfile
from hq.serializers.finance_profile_serializers import FinanceProfileSerializer


class FinanceProfileViewSet(viewsets.ModelViewSet):
    queryset = FinanceProfile.objects.all()
    serializer_class = FinanceProfileSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        return self.queryset.filter(user__id=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        user = get_object_or_404(get_user_model(), pk=user_pk)
        serializer.save(user=user)

    def perform_update(self, serializer):
        serializer.save(user=self.get_object().user)
