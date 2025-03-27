"""
------------------Prologue--------------------
File Name: task_category_progress_serializers.py
Path: kobrasuitecore/hq/serializers/task_category_progress_serializers.py

Date Created:
2025-03-15

Date Updated:
2025-03-16

Description:
(TEMP) This file contains Django REST Framework serializers for tracking user progress in task categories. It serializes TaskCategoryProgress model instances into JSON representations and vice versa.

Input:
(TEMP) TaskCategoryProgress model instances with profile, module, category ID, completion counts, and renewal timestamps.

Output:
(TEMP) Serialized JSON data containing progress metrics for task categories, including profile associations and completion statuses.

Collaborators: JAKE BERNARD, QWQ 32B
---------------------------------------------
"""
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
