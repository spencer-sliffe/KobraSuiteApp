"""
------------------Prologue--------------------
File Name: task_performance_bounds_serializers.py
Path: kobrasuitecore/hq/serializers/task_performance_bounds_serializers.py

Date Created:
2025-03-15

Date Updated:
2025-03-16

Description:
(TEMP) This module defines a Django REST Framework serializer for the TaskPerformanceBounds model, serializing progress, slot index, and data fields.

Input:
(TEMP) Input is an instance of the TaskPerformanceBounds model.

Output:
(TEMP) Output is a serialized JSON representation containing progress, slot index, and data fields.

Collaborators: JAKE BERNARD, QWQ 32B
---------------------------------------------
"""
from rest_framework import serializers
from hq.models import TaskPerformanceBounds

# (TEMP) Serializer class for the TaskPerformanceBounds model
class TaskPerformanceBoundsSerializer(serializers.ModelSerializer):
    # (TEMP) Inner class to configure the serializer's behavior
    class Meta:
        # (TEMP) Specifies the associated database model
        model = TaskPerformanceBounds
        # (TEMP) Lists the fields to include in serialization
        fields = [
            'progress',
            'slot_index',
            'data'
        ]
