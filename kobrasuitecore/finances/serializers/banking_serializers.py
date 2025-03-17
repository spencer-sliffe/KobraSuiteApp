"""
------------------Prologue--------------------
File Name: banking_serializer.py
Path: kobrasuitecore\finances\serializers\banking_serializers.py

Description:
Converts Django models into JSON for sendable format

Input:
Django models

Output:
JSON representation of Django Models

Collaborators: SPENCER SLIFFE,Charlie Gillund
---------------------------------------------
"""

from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from finances.models import BankAccount, Budget, BudgetCategory, Transaction

#declares Serializer for the Bank Account Models
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

#declares Serializer for the Budget Models
class BudgetSerializer(serializers.ModelSerializer):
    categories = serializers.StringRelatedField(many=True, read_only=True)
    #Defines structure for the serializer
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
    # function used to ensure value is nonnegative
    def validate_total_amount(self, value):
        if value < 0:
            raise ValidationError('Total amount cannot be negative.')
        return value
#Validates the dates to make sure they are valid
    def validate(self, data):
        start_date = data.get('start_date')
        end_date = data.get('end_date')
        if start_date and end_date and end_date < start_date:
            raise ValidationError('End date cannot be before start date.')
        return data

# defines the Budget categorey serializer 
class BudgetCategorySerializer(serializers.ModelSerializer):
    budget = serializers.PrimaryKeyRelatedField(queryset=Budget.objects.all())
#Defines structure for the serializer
    class Meta:
        model = BudgetCategory
        fields = [
            'id',
            'name',
            'budget',
            'allocated_amount',
            'category_type'
        ]
# Validates the amount within the serializer
    def validate_allocated_amount(self, value):
        if value < 0:
            raise ValidationError('Allocated amount cannot be negative.')
        return value

# Declares the transaction serializer
class TransactionSerializer(serializers.ModelSerializer):
    budget_category = serializers.PrimaryKeyRelatedField(queryset=BudgetCategory.objects.all())
# Defines structure for the serializer
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
# function to validate the amount 
    def validate_amount(self, value):
        if value < 0:
            raise ValidationError('Transaction amount cannot be negative.')
        return value