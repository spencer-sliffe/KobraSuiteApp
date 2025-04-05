"""
------------------Prologue--------------------
File Name: banking_serializers.py
Path: kobrasuitecore\finances\serializers\banking_serializers.py

Description:
Converts Django models into JSON for a sendable format.

Input:
Django models

Output:
JSON representations of Django models

Collaborators: SPENCER SLIFFE, Charlie Gillund
---------------------------------------------
"""
from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from finances.models import BankAccount, Budget, BudgetCategory, Transaction


class BankAccountSerializer(serializers.ModelSerializer):
    """
    Serializer for BankAccount model.
    """
    class Meta:
        model = BankAccount
        fields = [
            'id',
            'finance_profile',
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
    """
    Serializer for Budget model. Includes read-only categories
    displayed by their string representation.
    """
    categories = serializers.StringRelatedField(many=True, read_only=True)

    class Meta:
        model = Budget
        fields = [
            'id',
            'finance_profile',
            'name',
            'total_amount',
            'start_date',
            'end_date',
            'is_active',
            'categories'
        ]

    def validate_total_amount(self, value):
        """
        Ensures the total budget amount is nonnegative.
        """
        if value < 0:
            raise ValidationError('Total amount cannot be negative.')
        return value

    def validate(self, data):
        """
        Ensures end_date is not before start_date.
        """
        start_date = data.get('start_date')
        end_date = data.get('end_date')
        if start_date and end_date and end_date < start_date:
            raise ValidationError('End date cannot be before start date.')
        return data


class BudgetCategorySerializer(serializers.ModelSerializer):
    """
    Serializer for BudgetCategory model.
    """
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

    def validate_allocated_amount(self, value):
        """
        Ensures the allocated amount is nonnegative.
        """
        if value < 0:
            raise ValidationError('Allocated amount cannot be negative.')
        return value


class TransactionSerializer(serializers.ModelSerializer):
    """
    Serializer for Transaction model.
    """
    budget_category = serializers.PrimaryKeyRelatedField(queryset=BudgetCategory.objects.all())

    class Meta:
        model = Transaction
        fields = [
            'id',
            'finance_profile',
            'bank_account',
            'budget_category',
            'transaction_type',
            'amount',
            'description',
            'date',
            'created_at'
        ]
        read_only_fields = ['created_at']

    def validate_amount(self, value):
        """
        Ensures the transaction amount is nonnegative.
        """
        if value < 0:
            raise ValidationError('Transaction amount cannot be negative.')
        return value