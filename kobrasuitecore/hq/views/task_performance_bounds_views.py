"""
------------------Prologue--------------------
File Name: task_performance_bounds_views.py
Path: kobrasuitecore/hq/views/task_performance_bounds_views.py

Date Created:
2025-03-12

Date Updated:
2025-03-16

Description:
Manages API endpoints for TaskPerformanceBounds with permissions and serialization. Handles CRUD operations using Django REST Framework's ModelViewSet.

Input:
HTTP requests for TaskPerformanceBounds data including GET, POST, PUT, and DELETE operations.

Output:
Serialized TaskPerformanceBounds data and HTTP responses with status codes indicating operation success/failure.

Collaborators: JAKE BERNARD, QWQ 32B
---------------------------------------------
"""
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticatedOrReadOnly

from hq.models import TaskPerformanceBounds
from hq.serializers.task_performance_bounds_serializers import TaskPerformanceBoundsSerializer

class TaskPerformanceBoundsViewSet(viewsets.ModelViewSet):
    # (TEMP) Define queryset for TaskPerformanceBounds model instances
    queryset = TaskPerformanceBounds.objects.all()
    # (TEMP) Specify serializer class for data conversion
    serializer_class = TaskPerformanceBoundsSerializer
    # (TEMP) Set permission requirements: public read access or owner/admin for modifications
    permission_classes = (IsAuthenticatedOrReadOnly)
