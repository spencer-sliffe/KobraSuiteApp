from rest_framework import serializers
from hq.models import TaskCategoryProgress


class TaskCategoryProgressSerializer(serializers.ModelSerializer):


    class Meta:
        model = TaskCategoryProgress
        fields = [
            'profile',
            'module',
            'category_id',
            'completion_count',
            'last_renewed_at'
        ]