from rest_framework import serializers
from homelife.models import Household


class HouseholdSerializer(serializers.ModelSerializer):
    class Meta:
        model = Household
        fields = '__all__'