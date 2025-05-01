from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.response import Response
from hq.models import TaskCategoryProgress
from hq.serializers.task_category_progress_serializers import TaskCategoryProgressSerializer
from hq.utils.task_utils import apply_task_rewards


class TaskCategoryProgressViewSet(viewsets.ModelViewSet):
    # (TEMP) Base queryset for task category progress objects
    queryset = TaskCategoryProgress.objects.all()
    # (TEMP) Serializer for task category progress data
    serializer_class = TaskCategoryProgressSerializer
    # (TEMP) Permission requiring authentication or read-only access, with owner/admin checks
    permission_classes = (IsAuthenticatedOrReadOnly)

    @action(methods=['post'], detail=True)
    def complete(self, request, module, task_category_num, task_slot_id=-1, data=None):
        # (TEMP) Retrieve user profile from request object
        profile = getattr(request.user, 'user_profile', None)
        # (TEMP) Apply task completion logic and reward calculation
        return apply_task_rewards(profile, module, task_category_num, task_slot_id, data)

    # TODO: (JAKE, TASK VIEWS) Do we need these? These methods should already exist

    # We should've just used signals...

    # def get_queryset(self):
    #     user_pk = self.kwargs.get('user_pk')
    #     module_type = self.kwargs.get('module')
    #     return self.queryset.filter(module=module_type, profile=user_pk)
    #
    # def perform_create(self, serializer):
    #     user_pk = self.kwargs.get('user_pk')
    #     module_type = self.kwargs.get('module')
    #     serializer.save(profile=user_pk, module=module_type)
    #
    # def perform_update(self, serializer):
    #     serializer.save(profile=self.get_object().profile, module=self.get_object().module)
