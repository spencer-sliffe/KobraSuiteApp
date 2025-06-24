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
