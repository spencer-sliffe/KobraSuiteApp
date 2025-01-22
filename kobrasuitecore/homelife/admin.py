# homelife/admin.py

from django.contrib import admin
from .models import (
    Household, Chore, SharedCalendarEvent, MealPlan,
    GroceryItem
)

@admin.register(Household)
class HouseholdAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at')
    search_fields = ('name',)
    filter_horizontal = ('members',)

@admin.register(Chore)
class ChoreAdmin(admin.ModelAdmin):
    list_display = ('title', 'household', 'frequency', 'priority', 'due_date', 'assigned_to')
    search_fields = ('title', 'household__name', 'assigned_to__username')
    list_filter = ('frequency', 'priority', 'due_date')

@admin.register(SharedCalendarEvent)
class SharedCalendarEventAdmin(admin.ModelAdmin):
    list_display = ('title', 'household', 'start_datetime', 'end_datetime', 'location')
    search_fields = ('title', 'household__name')
    list_filter = ('start_datetime', 'end_datetime')

@admin.register(MealPlan)
class MealPlanAdmin(admin.ModelAdmin):
    list_display = ('recipe_name', 'household', 'date', 'meal_type')
    search_fields = ('recipe_name', 'household__name')
    list_filter = ('meal_type', 'date')

@admin.register(GroceryItem)
class GroceryItemAdmin(admin.ModelAdmin):
    list_display = ('name', 'household', 'quantity', 'purchased')
    search_fields = ('name', 'household__name')
    list_filter = ('purchased',)

