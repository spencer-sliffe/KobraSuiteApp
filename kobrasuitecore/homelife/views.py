from rest_framework import viewsets
from .models import Household, Chore, SharedCalendarEvent
# from .serializers import HouseholdSerializer, ChoreSerializer, EventSerializer

class HouseholdViewSet(viewsets.ModelViewSet):
    queryset = Household.objects.all()
    # serializer_class = HouseholdSerializer

class ChoreViewSet(viewsets.ModelViewSet):
    queryset = Chore.objects.all()
    # serializer_class = ChoreSerializer

class SharedCalendarEventViewSet(viewsets.ModelViewSet):
    queryset = SharedCalendarEvent.objects.all()
    # serializer_class = EventSerializer