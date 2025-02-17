from rest_framework import serializers
from .models import Budget, BudgetCategory, Transaction

class BudgetSerializer(serializers.ModelSerializer):
       categories = serializers.StringRelatedField(many=True, read_only=True)

       class Meta:
            model = Budget
            fields = ['id', 'name', 'user', 'total_amount', 'start_date', 'end_date', 'is_active', 'categories']

class BudgetCategorySerializer(serializers.ModelSerializer):
       budget = serializers.PrimaryKeyRelatedField(queryset=Budget.objects.all())

       class Meta:
           model = BudgetCategory
           fields = ['id', 'name', 'budget', 'allocated_amount', 'category_type']

class TransactionSerializer(serializers.ModelSerializer):
       user = serializers.ReadOnlyField(source='user.username')
       budget_category = serializers.PrimaryKeyRelatedField(queryset=BudgetCategory.objects.all())

       class Meta:
           model = Transaction
           fields = ['id', 'transaction_type', 'amount', 'user', 'budget_category', 'description', 'date', 'created_at']
           read_only_fields = ['created_at']