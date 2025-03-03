
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from customer.permissions import IsOwnerOrAdmin
from hq.models import ModuleTask
from hq.serializers.module_task_serializers import ModuleTaskSerializer

class ModuleTaskViewSet(viewsets.ModelViewSet):
    queryset = ModuleTask.objects.all()
    serializer_class = ModuleTaskSerializer
    permission_classes = (IsAuthenticatedOrReadOnly, IsOwnerOrAdmin)

    @action()
    def complete(self, request):
        # task/complete/{module}/{task_name}/{weight}

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        module_type = self.kwargs.get('module_type')
        return self.queryset.filter(module=module_type, profile=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        module_type = self.kwargs.get('module_type')
        serializer.save(profile=user_pk, module=module_type)

    def perform_update(self, serializer):
        serializer.save(profile=self.get_object().profile, module=self.get_object().module)