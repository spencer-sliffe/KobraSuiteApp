from rest_framework import viewsets, permissions
from .models import BankAccount, Budget, Transaction, BudgetCategory
from rest_framework.decorators import action

class BankAccountViewSet(viewsets.ModelViewSet):
    queryset = BankAccount.objects.all()
    # serializer_class = BankAccountSerializer

class BudgetViewSet(viewsets.ModelViewSet):
    queryset = Budget.objects.all()
    serializer_class = BudgetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users can only see their own budgets
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class BudgetCategoryViewSet(viewsets.ModelViewSet):
    queryset = BudgetCategory.objects.all()
    serializer_class = BudgetCategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users can only see categories under their own budgets
        return self.queryset.filter(budget__user=self.request.user)

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users can only see their own transactions
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)