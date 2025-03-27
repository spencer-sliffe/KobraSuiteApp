"""
------------------Prologue--------------------
File Name: task_category_slots_serializers.py
Path: kobrasuitecore/hq/serializers/task_category_slots_serializers.py

Date Created:
2025-03-15

Date Updated:
2025-03-16

Description:
(TEMP) Defines a Django REST Framework serializer for the TaskCategorySlots model, specifying fields 'progress', 'slots', and 'completed' for serialization and deserialization.

Input:
(TEMP) Instances of the TaskCategorySlots model to be serialized or deserialized.

Output:
(TEMP) Serialized data in JSON or XML format containing the specified fields.

Collaborators: JAKE BERNARD, QWQ 32B
---------------------------------------------
"""
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
