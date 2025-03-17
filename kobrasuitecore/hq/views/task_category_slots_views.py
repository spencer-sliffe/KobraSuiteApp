# This is left intentionally blank:
# we should never expose this object to the frontend
# TODO: (JAKE, TASK SLOTS VIEWS) Remove this later
#
# from rest_framework import viewsets
# from rest_framework.permissions import IsAuthenticatedOrReadOnly
#
# from customer.permissions import IsOwnerOrAdmin
# from hq.models import TaskCategorySlots
# from hq.serializers.task_category_slots_serializers import TaskCategorySlotsSerializer
#
#
# class TaskCategorySlotsViewSet(viewsets.ModelViewSet):
#     queryset = TaskCategorySlots.objects.all()
#     serializer_class = TaskCategorySlotsSerializer
#     permission_classes = (IsAuthenticatedOrReadOnly, IsOwnerOrAdmin)