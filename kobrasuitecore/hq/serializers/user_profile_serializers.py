from rest_framework import serializers

from hq.models import UserProfile
from hq.serializers.finance_profile_serializers import FinanceProfileSerializer
from hq.serializers.homelife_profile_serializers import HomeLifeProfileSerializer
from hq.serializers.school_profile_serializers import SchoolProfileSerializer
from hq.serializers.work_profile_serializers import WorkProfileSerializer


class UserProfileSerializer(serializers.ModelSerializer):
    school_profile = SchoolProfileSerializer(read_only=True)
    work_profile = WorkProfileSerializer(read_only=True)
    finance_profile = FinanceProfileSerializer(read_only=True)
    homelife_profile = HomeLifeProfileSerializer(read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            'id', 'user', 'date_of_birth', 'address', 'profile_picture', 'preferences',
            'school_profile', 'work_profile', 'finance_profile', 'homelife_profile'
        ]
        # Usually you do not update 'user' from here, so that can be read-only as well.
        read_only_fields = ['user']