from django.db import transaction
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from finances.models import BankAccount, Budget, BudgetCategory, Transaction
from finances.serializers.banking_serializers import BankAccountSerializer, BudgetSerializer, BudgetCategorySerializer, \
    TransactionSerializer


class BankAccountViewSet(viewsets.ModelViewSet):
    serializer_class = BankAccountSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return BankAccount.objects.filter(profile__user=self.request.user)


class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Budget.objects.filter(profile__user=self.request.user)


class BudgetCategoryViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetCategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return BudgetCategory.objects.filter(budget__profile__user=self.request.user)


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Transaction.objects.filter(profile__user=self.request.user)

    def perform_create(self, serializer):
        with transaction.atomic():
            instance = serializer.save(profile=self.request.user.finance_profile)
            if instance.bank_account and instance.transaction_type in ['EXPENSE', 'INCOME']:
                if instance.transaction_type == 'EXPENSE':
                    if instance.amount > instance.bank_account.balance:
                        raise ValidationError('Insufficient account balance for this expense.')
                    instance.bank_account.balance -= instance.amount
                else:
                    instance.bank_account.balance += instance.amount
                instance.bank_account.save()

    def perform_update(self, serializer):
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