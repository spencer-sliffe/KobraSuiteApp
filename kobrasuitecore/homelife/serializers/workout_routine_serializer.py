from rest_framework import serializers
from homelife.models import WorkoutRoutine


class WorkoutRoutineSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutRoutine
        fields = '__all__'