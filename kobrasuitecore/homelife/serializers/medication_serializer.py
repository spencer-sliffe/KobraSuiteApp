from rest_framework import serializers
from homelife.models import Medication


class MedicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medication
        fields = '__all__'