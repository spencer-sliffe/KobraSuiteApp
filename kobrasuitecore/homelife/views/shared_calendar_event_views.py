from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import SharedCalendarEvent, Household
from homelife.serializers.shared_calendar_event_serializer import SharedCalendarEventSerializer


class SharedCalendarEventViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/calendar_events/
    """
    serializer_class = SharedCalendarEventSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return SharedCalendarEvent.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)