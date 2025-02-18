# hq/serializers/multiplier_serializers.py
from rest_framework import serializers

from hq.models import HomeLifeProfile


class HomeLifeProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = HomeLifeProfile
        fields = [
            'id',
        ]
