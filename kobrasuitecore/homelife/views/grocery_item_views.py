from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import GroceryItem, GroceryList
from homelife.serializers.grocery_item_serializer import GroceryItemSerializer


class GroceryItemViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router → grocery_router:
    /.../households/<household_pk>/grocery_lists/<grocery_list_pk>/grocery_items/<grocery_item_pk>/
    """
    serializer_class = GroceryItemSerializer

    # --- READ ---------------------------------------------------------------
    def get_queryset(self):
        """
        Return only the items that belong to the nested grocery_list_pk.
        """
        grocery_list_id = self.kwargs.get('grocery_list_pk')
        return GroceryItem.objects.filter(grocery_list_id=grocery_list_id)

    # --- CREATE -------------------------------------------------------------
    def perform_create(self, serializer):
        """
        Attach the item to the correct GroceryList (and by extension its household).
        """
        grocery_list = get_object_or_404(
            GroceryList,
            pk=self.kwargs.get('grocery_list_pk')
        )
        serializer.save(grocery_list=grocery_list)