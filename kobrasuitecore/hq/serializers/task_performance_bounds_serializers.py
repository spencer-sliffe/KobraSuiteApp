from rest_framework import serializers
from hq.models import TaskPerformanceBounds


class TaskPerformanceBoundsSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaskPerformanceBounds
        fields = [
            'progress',
            'slot_index',
            'data'
        ]