# hq/serializers/multiplier_serializers.py
from rest_framework import serializers

from hq.models import ModuleTask

class ModuleTaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModuleTask
        fields = [
            'profile',
            'date',
            'module',
            'task_number',
            'task_weight'
        ]