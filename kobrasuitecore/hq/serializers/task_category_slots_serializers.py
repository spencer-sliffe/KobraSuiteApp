from rest_framework import serializers
from hq.models import TaskCategorySlots

# (TEMP) Define serializer for TaskCategorySlots model
class TaskCategorySlotsSerializer(serializers.ModelSerializer):
    # (TEMP) Define metadata configuration for the serializer
    class Meta:
        # (TEMP) Associate the serializer with the TaskCategorySlots database model
        model = TaskCategorySlots
        # (TEMP) Specify the list of fields to include in serialization/deserialization
        fields = [
            'progress',
            'slots',
            'completed'
        ]
