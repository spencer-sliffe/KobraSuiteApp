# finances/admin.py

from django.contrib import admin
from .models import (
    BankAccount, Budget, BudgetCategory, Transaction,
    Bill, Debt, SavingsGoal
)

@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = ('account_name', 'user', 'balance', 'currency', 'last_synced')
    search_fields = ('account_name', 'user__username', 'institution_name')
    list_filter = ('currency',)

@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'total_amount', 'start_date', 'end_date', 'is_active')
    search_fields = ('name', 'user__username')
    list_filter = ('is_active',)

@admin.register(BudgetCategory)
class BudgetCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'budget', 'allocated_amount')
    search_fields = ('name', 'budget__name')

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_type', 'amount', 'user', 'date', 'created_at')
    search_fields = ('user__username', 'description')
    list_filter = ('transaction_type', 'date', 'created_at')

@admin.register(Bill)
class BillAdmin(admin.ModelAdmin):
    list_display = ('name', 'amount', 'user', 'due_date', 'recurring_interval', 'is_auto_pay_enabled')
    search_fields = ('name', 'user__username')
    list_filter = ('recurring_interval', 'due_date', 'is_auto_pay_enabled')

@admin.register(Debt)
class DebtAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'remaining_balance', 'debt_type', 'due_date', 'created_at')
    search_fields = ('name', 'user__username')
    list_filter = ('debt_type', 'created_at')

@admin.register(SavingsGoal)
class SavingsGoalAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'target_amount', 'current_amount', 'deadline', 'created_at')
    search_fields = ('name', 'user__username')
    list_filter = ('deadline', 'created_at')
