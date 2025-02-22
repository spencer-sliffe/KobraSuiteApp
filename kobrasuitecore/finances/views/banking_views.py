from rest_framework import viewsets, permissions
from finances.models import BankAccount, Budget, BudgetCategory, Transaction
from finances.serializers.banking_serializers import (
    BankAccountSerializer,
    BudgetSerializer,
    BudgetCategorySerializer,
    TransactionSerializer
)

class BankAccountViewSet(viewsets.ModelViewSet):
    queryset = BankAccount.objects.all()
    serializer_class = BankAccountSerializer
    permission_classes = [permissions.IsAuthenticated]
    def get_queryset(self):
        if self.request.user.finance_profile:
            return self.queryset.filter(profile=self.request.user.finance_profile)
        return self.queryset.none()
    def perform_create(self, serializer):
        serializer.save(profile=self.request.user.finance_profile)

class BudgetViewSet(viewsets.ModelViewSet):
    queryset = Budget.objects.all()
    serializer_class = BudgetSerializer
    permission_classes = [permissions.IsAuthenticated]
    def get_queryset(self):
        if self.request.user.finance_profile:
            return self.queryset.filter(profile=self.request.user.finance_profile)
        return self.queryset.none()
    def perform_create(self, serializer):
        serializer.save(profile=self.request.user.finance_profile)

class BudgetCategoryViewSet(viewsets.ModelViewSet):
    queryset = BudgetCategory.objects.all()
    serializer_class = BudgetCategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    def get_queryset(self):
        if self.request.user.finance_profile:
            return self.queryset.filter(budget__profile=self.request.user.finance_profile)
        return self.queryset.none()
    def perform_create(self, serializer):
        budget = serializer.validated_data.get('budget')
        if budget and budget.profile == self.request.user.finance_profile:
            serializer.save()
        else:
            raise PermissionError("You do not have permission to add a category to this budget.")

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]
    def get_queryset(self):
        if self.request.user.finance_profile:
            return self.queryset.filter(profile=self.request.user.finance_profile)
        return self.queryset.none()
    def perform_create(self, serializer):
        serializer.save(profile=self.request.user.finance_profile)