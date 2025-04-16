from rest_framework import serializers
from homelife.models import ChoreCompletion

class ChoreCompletionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChoreCompletion
        fields = '__all__'