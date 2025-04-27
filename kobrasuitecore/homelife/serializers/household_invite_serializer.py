from rest_framework import serializers
from homelife.models import HouseholdInvite


class HouseholdInviteSerializer(serializers.ModelSerializer):
    class Meta:
        model  = HouseholdInvite
        fields = ('id', 'household', 'code', 'created_at')
        read_only_fields = ('id', 'created_at')