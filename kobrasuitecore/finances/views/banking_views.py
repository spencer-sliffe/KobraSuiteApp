"""
------------------Prologue--------------------
File Name: stock_views.py
Path: kobrasuitecore/finances/views/Banking_views.py

Description:
Implements endpoints for Banking functions: viewing banking info/ created budgets. functions to view manage and create transactions

Input:
User data
Output:
Structured JSON containing updated Banking,Budget and Tranactions.

Collaborators: SPENCER SLIFFE,Charlie Gillund
---------------------------------------------
"""


from django.db import transaction
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from finances.models import BankAccount, Budget, BudgetCategory, Transaction
from finances.serializers.banking_serializers import BankAccountSerializer, BudgetSerializer, BudgetCategorySerializer, \
    TransactionSerializer


class BankAccountViewSet(viewsets.ModelViewSet): # Banking view
    serializer_class = BankAccountSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return BankAccount.objects.filter(profile__user=self.request.user) # gets user baking info


class BudgetViewSet(viewsets.ModelViewSet): # Budget view set
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Budget.objects.filter(profile__user=self.request.user) # gets users budget


class BudgetCategoryViewSet(viewsets.ModelViewSet): # gets budget catergories
    serializer_class = BudgetCategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return BudgetCategory.objects.filter(budget__profile__user=self.request.user) # gets users budget catergoreies


class TransactionViewSet(viewsets.ModelViewSet): # transaction view set
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Transaction.objects.filter(profile__user=self.request.user) # gets users transactions

    def perform_create(self, serializer): # used to create transactions
        with transaction.atomic(): # makes transactions atomic and update corresponding models
            instance = serializer.save(profile=self.request.user.profile.finance_profile)
            if instance.bank_account and instance.transaction_type in ['EXPENSE', 'INCOME']:
                if instance.transaction_type == 'EXPENSE':
                    if instance.amount > instance.bank_account.balance:
                        raise ValidationError('Insufficient account balance for this expense.')
                    instance.bank_account.balance -= instance.amount
                else:
                    instance.bank_account.balance += instance.amount
                instance.bank_account.save()

    def perform_update(self, serializer): # used to update models 
        old_instance = self.get_object()
        old_amount = old_instance.amount
        with transaction.atomic(): # makes update atomics and updates transations
            new_instance = serializer.save()
            if new_instance.bank_account and new_instance.transaction_type in ['EXPENSE', 'INCOME']:
                difference = new_instance.amount - old_amount
                if new_instance.transaction_type == 'EXPENSE':
                    if difference > 0 and new_instance.bank_account.balance < difference:
                        raise ValidationError('Insufficient account balance to increase expense.')
                    new_instance.bank_account.balance -= difference
                else:
                    new_instance.bank_account.balance += difference
                new_instance.bank_account.save()