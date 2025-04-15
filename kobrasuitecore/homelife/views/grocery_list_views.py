from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import GroceryItem, Household
from homelife.serializers.grocery_item_serializer import GroceryItemSerializer


class GroceryListSerializer:
    pass


class GroceryListViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/grocery_lists/
    """
    serializer_class = GroceryListSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return GroceryItem.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)