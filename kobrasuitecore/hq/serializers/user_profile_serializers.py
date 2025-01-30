from rest_framework import serializers

from hq.models import UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'date_of_birth', 'address', 'profile_picture', 'preferences',
        ]

