from rest_framework import serializers
from homelife.models import GroceryList


class GroceryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroceryList
        fields = '__all__'