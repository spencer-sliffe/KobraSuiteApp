from rest_framework import viewsets, permissions
from django.utils import timezone
from homelife.models import SharedCalendarEvent, Household
from homelife.serializers.shared_calendar_event_serializer import (
    SharedCalendarEventSerializer,
)


class SharedCalendarEventViewSet(viewsets.ModelViewSet):
    """
    /…/households/<household_pk>/calendar_events/
    List, create, update or delete events.
    Supports ?start=<iso>&end=<iso> filtering.
    """
    serializer_class = SharedCalendarEventSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        hh = self.kwargs["household_pk"]
        qs = SharedCalendarEvent.objects.filter(household_id=hh)
        start = self.request.query_params.get("start")
        end = self.request.query_params.get("end")
        if start:
            qs = qs.filter(end_datetime__gte=start)
        if end:
            qs = qs.filter(start_datetime__lte=end)
        return qs.order_by("start_datetime")

    def perform_create(self, serializer):
        hh = Household.objects.get(pk=self.kwargs["household_pk"])
        serializer.save(household=hh)