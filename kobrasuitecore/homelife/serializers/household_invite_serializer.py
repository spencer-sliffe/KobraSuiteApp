from rest_framework import serializers
from homelife.models import HouseholdInvite


class HouseholdInviteSerializer(serializers.ModelSerializer):
    class Meta:
        model = HouseholdInvite
        fields = '__all__'