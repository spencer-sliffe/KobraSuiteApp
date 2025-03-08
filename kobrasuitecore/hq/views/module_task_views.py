from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework.response import Response
from customer.permissions import IsOwnerOrAdmin
from hq.models import ModuleTask
from hq.serializers.module_task_serializers import ModuleTaskSerializer
from hq.utils.task_utils import apply_task_rewards


class ModuleTaskViewSet(viewsets.ModelViewSet):
    queryset = ModuleTask.objects.all()
    serializer_class = ModuleTaskSerializer
    permission_classes = (IsAuthenticatedOrReadOnly, IsOwnerOrAdmin)

    @action(methods=['post'], detail=True)
    def complete(self, request, pk=None):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        task = serializer.save()
        currency, experience, population, task_completed, has_reward, performance, has_ranked_up = apply_task_rewards(task)
        return Response({
            "task_completed": task_completed,
            "has_reward": has_reward,
            "performance": performance,
            "currency": currency,
            "experience": experience,
            "population": population,
            "has_ranked_up": has_ranked_up
        }, status=status.HTTP_200_OK)

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        module_type = self.kwargs.get('module_type')
        return self.queryset.filter(module=module_type, profile=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        module_type = self.kwargs.get('module_type')
        serializer.save(profile_id=user_pk, module=module_type)

    def perform_update(self, serializer):
        serializer.save(profile=self.get_object().profile, module=self.get_object().module)