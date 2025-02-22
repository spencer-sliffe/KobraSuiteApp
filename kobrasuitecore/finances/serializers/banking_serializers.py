from rest_framework import serializers
from finances.models import BankAccount, Budget, BudgetCategory, Transaction


class BankAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = BankAccount
        fields = [
            'id',
            'profile',
            'account_name',
            'account_number',
            'institution_name',
            'balance',
            'currency',
            'last_synced',
            'created_at',
            'updated_at'
        ]


class BudgetSerializer(serializers.ModelSerializer):
    categories = serializers.StringRelatedField(many=True, read_only=True)
    class Meta:
        model = Budget
        fields = [
            'id',
            'profile',
            'name',
            'total_amount',
            'start_date',
            'end_date',
            'is_active',
            'categories'
        ]


class BudgetCategorySerializer(serializers.ModelSerializer):
    budget = serializers.PrimaryKeyRelatedField(queryset=Budget.objects.all())
    class Meta:
        model = BudgetCategory
        fields = [
            'id',
            'name',
            'budget',
            'allocated_amount',
            'category_type'
        ]


class TransactionSerializer(serializers.ModelSerializer):
    budget_category = serializers.PrimaryKeyRelatedField(queryset=BudgetCategory.objects.all())
    class Meta:
        model = Transaction
        fields = [
            'id',
            'profile',
            'bank_account',
            'budget_category',
            'transaction_type',
            'amount',
            'description',
            'date',
            'created_at'
        ]
        read_only_fields = ['created_at']