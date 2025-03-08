from rest_framework import serializers
from hq.models import ModuleTask


class ModuleTaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModuleTask
        fields = [
            'profile',
            'date',
            'module',
            'category_id',
            'unique_task_id',
            'task_weight'
        ]