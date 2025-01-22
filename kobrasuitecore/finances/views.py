from rest_framework import viewsets
from .models import BankAccount, Budget, Transaction

class BankAccountViewSet(viewsets.ModelViewSet):
    queryset = BankAccount.objects.all()
    # serializer_class = BankAccountSerializer

class BudgetViewSet(viewsets.ModelViewSet):
    queryset = Budget.objects.all()
    # serializer_class = BudgetSerializer

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    # serializer_class = TransactionSerializer