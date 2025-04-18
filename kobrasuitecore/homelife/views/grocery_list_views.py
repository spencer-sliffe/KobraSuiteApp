from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import GroceryItem, Household, GroceryList
from homelife.serializers.grocery_list_serializer import GroceryListSerializer


class GroceryListViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/grocery_lists/
    """
    serializer_class = GroceryListSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return GroceryList.objects.filter(household=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)