from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import MedicalAppointment, Household
from homelife.serializers.medical_appointment_serializer import MedicalAppointmentSerializer


class MedicalAppointmentViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/medical_appointments/
    """
    serializer_class = MedicalAppointmentSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return MedicalAppointment.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)