from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from homelife.models import MealPlan, Household
from homelife.serializers.meal_plan_serializer import MealPlanSerializer


class MealPlanViewSet(viewsets.ModelViewSet):
    """
    Nested under household_router:
    e.g. /.../households/<household_pk>/meal_plans/
    """
    serializer_class = MealPlanSerializer

    def get_queryset(self):
        household_id = self.kwargs.get('household_pk')
        return MealPlan.objects.filter(household_id=household_id)

    def perform_create(self, serializer):
        household_id = self.kwargs.get('household_pk')
        household = get_object_or_404(Household, pk=household_id)
        serializer.save(household=household)