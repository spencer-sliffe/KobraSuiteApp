from rest_framework import serializers
from hq.models import TaskCategoryProgress

# (TEMP) Main serializer class for TaskCategoryProgress model instances
class TaskCategoryProgressSerializer(serializers.ModelSerializer):

    # (TEMP) Configuration class for the serializer
    class Meta:
        # (TEMP) Specifies the model class for the serializer
        model = TaskCategoryProgress
        # (TEMP) Defines the list of fields to include in serialization
        fields = [
            # (TEMP) Foreign key to the user profile
            'profile',
            # (TEMP) Module associated with the progress
            'module',
            # (TEMP) Unique identifier for the category
            'category_id',
            # (TEMP) Count of completed tasks in the category
            'completion_count',
            # (TEMP) Timestamp of the last progress renewal
            'last_renewed_at'
        ]
