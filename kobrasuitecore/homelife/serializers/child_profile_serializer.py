from rest_framework import serializers
from homelife.models import ChildProfile


class ChildProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChildProfile
        fields = '__all__'