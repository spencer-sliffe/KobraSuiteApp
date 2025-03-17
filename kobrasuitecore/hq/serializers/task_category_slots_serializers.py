from rest_framework import serializers
from hq.models import TaskCategorySlots


class TaskCategorySlotsSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaskCategorySlots
        fields = [
            'progress',
            'slots',
            'completed'
        ]