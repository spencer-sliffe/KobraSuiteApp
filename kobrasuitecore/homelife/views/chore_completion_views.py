from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import ChoreCompletion, Chore
from homelife.serializers.chore_completion_serializer import ChoreCompletionSerializer


class ChoreCompletionViewSet(viewsets.ModelViewSet):
    """
    Nested under chore_router:
    e.g. /.../households/<household_pk>/chores/<chore_pk>/completions/
    """
    serializer_class = ChoreCompletionSerializer

    def get_queryset(self):
        chore_id = self.kwargs.get('chore_pk')
        return ChoreCompletion.objects.filter(chore_id=chore_id)

    def perform_create(self, serializer):
        chore_id = self.kwargs.get('chore_pk')
        chore = get_object_or_404(Chore, pk=chore_id)
        serializer.save(chore=chore)