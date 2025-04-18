from rest_framework import viewsets
from rest_framework.exceptions import ValidationError

from homelife.models import Chore, Household
from homelife.serializers.chore_serializer import ChoreSerializer


class ChoreViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/chores/
    """
    serializer_class = ChoreSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return Chore.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        hh_pk = self.kwargs['household_pk']
        child = serializer.validated_data.get('child_assigned_to')
        adult = serializer.validated_data.get('assigned_to')

        if adult and adult.household_id != int(hh_pk):
            raise ValidationError("Adult assignee not in this household.")
        if child and child.parent_profile.household_id != int(hh_pk):
            raise ValidationError("Child assignee not in this household.")

        serializer.save(household_id=hh_pk)