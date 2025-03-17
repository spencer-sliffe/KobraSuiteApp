
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticatedOrReadOnly

from customer.permissions import IsOwnerOrAdmin
from hq.models import TaskPerformanceBounds
from hq.serializers.task_performance_bounds_serializers import TaskPerformanceBoundsSerializer


class TaskPerformanceBoundsViewSet(viewsets.ModelViewSet):
    queryset = TaskPerformanceBounds.objects.all()
    serializer_class = TaskPerformanceBoundsSerializer
    permission_classes = (IsAuthenticatedOrReadOnly, IsOwnerOrAdmin)