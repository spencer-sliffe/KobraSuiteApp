# homelife/serializers/chore_serializer.py
from rest_framework import serializers
from homelife.models import Chore


class ChoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chore
        fields = '__all__'

    def validate(self, attrs):
        if attrs.get('assigned_to') and attrs.get('child_assigned_to'):
            raise serializers.ValidationError("Choose either assigned_to or child_assigned_to—not both.")
        return attrs