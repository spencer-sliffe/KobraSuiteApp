from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import WorkoutRoutine, Household
from homelife.serializers.workout_routine_serializer import WorkoutRoutineSerializer


class WorkoutRoutineViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/workout_routines/
    """
    serializer_class = WorkoutRoutineSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return WorkoutRoutine.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)