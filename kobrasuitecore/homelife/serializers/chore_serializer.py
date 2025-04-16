from rest_framework import serializers
from homelife.models import Chore


class ChoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chore
        fields = '__all__'