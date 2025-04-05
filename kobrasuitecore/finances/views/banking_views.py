"""
------------------Prologue--------------------
File Name: banking_views.py
Path: kobrasuitecore/finances/views/banking_views.py

Description:
Implements endpoints for banking functions, including viewing and creating
bank accounts, budgets, categories, and transactions.

Input:
User data

Output:
Structured JSON containing updated banking, budgets, and transactions.

Collaborators: SPENCER SLIFFE, Charlie Gillund
---------------------------------------------
"""
from django.db import transaction
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from finances.models import BankAccount, Budget, BudgetCategory, Transaction
from finances.serializers.banking_serializers import (
    BankAccountSerializer,
    BudgetSerializer,
    BudgetCategorySerializer,
    TransactionSerializer
)


class BankAccountViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing bank accounts.
    """
    http_method_names = ['get', 'patch', 'post', 'retrieve', 'delete']
    queryset = BankAccount.objects.all()
    serializer_class = BankAccountSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/profile/<profile_pk>/finance_profile/<finance_profile_pk>/bank_accounts/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(
            finance_profile_id=finance_profile_pk,
            finance_profile__profile_id=profile_pk,
            finance_profile__profile__user_id=user_pk
        )


class BudgetViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing budgets.
    """
    http_method_names = ['get', 'patch', 'post', 'retrieve', 'delete']
    queryset = Budget.objects.all()
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/profile/<profile_pk>/finance_profile/<finance_profile_pk>/budgets/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(
            finance_profile_id=finance_profile_pk,
            finance_profile__profile_id=profile_pk,
            finance_profile__profile__user_id=user_pk
        )


class BudgetCategoryViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing budget categories.
    """
    http_method_names = ['get', 'patch', 'post', 'retrieve', 'delete']
    queryset = BudgetCategory.objects.all()
    serializer_class = BudgetCategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/profile/<profile_pk>/finance_profile/<finance_profile_pk>/budgets/<budget_pk>/categories/
        Because a BudgetCategory references Budget, we match all the way back.
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(
            budget__finance_profile_id=finance_profile_pk,
            budget__finance_profile__profile_id=profile_pk,
            budget__finance_profile__profile__user_id=user_pk
        )


class TransactionViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing transactions.
    """
    http_method_names = ['get', 'patch', 'post', 'retrieve', 'delete']
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/profile/<profile_pk>/finance_profile/<finance_profile_pk>/transactions/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(
            finance_profile_id=finance_profile_pk,
            finance_profile__profile_id=profile_pk,
            finance_profile__profile__user_id=user_pk
        )

    def perform_create(self, serializer):
        """
        Creates a new transaction and updates the related bank account balance
        if the transaction is an EXPENSE or INCOME.
        """
        with transaction.atomic():
            instance = serializer.save(finance_profile=self.kwargs["finance_profile_pk"])
            if instance.bank_account and instance.transaction_type in ['EXPENSE', 'INCOME']:
                if instance.transaction_type == 'EXPENSE':
                    if instance.amount > instance.bank_account.balance:
                        raise ValidationError('Insufficient account balance for this expense.')
                    instance.bank_account.balance -= instance.amount
                else:
                    instance.bank_account.balance += instance.amount
                instance.bank_account.save()

    def perform_update(self, serializer):
        """
        Updates an existing transaction and adjusts the bank account balance
        based on the difference in amount, if the transaction is an EXPENSE or INCOME.
        """
        old_instance = self.get_object()
        old_amount = old_instance.amount
        with transaction.atomic():
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