from rest_framework import serializers
from homelife.models import GroceryItem


class GroceryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroceryItem
        fields = '__all__'