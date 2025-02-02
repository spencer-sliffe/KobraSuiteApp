from rest_framework import serializers

from hq.models import WorkProfile


class WorkProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkProfile
        fields = [
            'id'
        ]
