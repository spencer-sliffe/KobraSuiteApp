from rest_framework import serializers
from homelife.models import MedicalAppointment


class MedicalAppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = MedicalAppointment
        fields = '__all__'