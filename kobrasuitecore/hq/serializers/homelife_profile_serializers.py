from rest_framework import serializers

from homelife.serializers.household_serializer import HouseholdSerializer
from hq.models import HomeLifeProfile


class HomeLifeProfileSerializer(serializers.ModelSerializer):
    # pull data from the joined tables
    user = serializers.IntegerField(source='profile.user_id', read_only=True)
    username = serializers.CharField(source='profile.user.username', read_only=True)
    household_detail = HouseholdSerializer(source='household', read_only=True)

    class Meta:
        model = HomeLifeProfile
        fields = [
            'id',
            'user',              # integer user PK
            'username',          # string username
            'household',         # household PK (nullable)
            'household_detail',  # nested object or null
        ]