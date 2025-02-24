from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated
from hq.models import CalendarEvent
from hq.serializers.calendar_serializers import CalendarEventSerializer


class CalendarEventViewSet(ModelViewSet):
    queryset = CalendarEvent.objects.all()
    serializer_class = CalendarEventSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if not user.is_authenticated:
            return qs.none()
        return qs.filter(profile__user=user)