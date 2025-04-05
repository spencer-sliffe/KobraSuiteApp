# """
# ------------------Prologue--------------------
# File Name: stock_utils.py
# Path: kobrasuitecore\finances\models.py
#
# Description:
# Structures and creates Django models used within the Finance module.
#
# Input:
# N/A
#
# Output:
# Django Models
#
# Collaborators: SPENCER SLIFFE, Charlie Gillund
# ---------------------------------------------
# """
from django.db import models
from django.utils import timezone
from hq.models import FinanceProfile
from .types import CategoryType
from django.db.models import Sum


class StockPortfolio(models.Model):
    finance_profile = models.ForeignKey(
        FinanceProfile,
        on_delete=models.CASCADE,
        related_name='stock_portfolios'
    )
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class PortfolioStock(models.Model):
    portfolio = models.ForeignKey(
        StockPortfolio,
        on_delete=models.CASCADE,
        related_name='stocks'
    )
    ticker = models.CharField(max_length=12)
    number_of_shares = models.IntegerField()
    pps_at_purchase = models.FloatField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class WatchlistStock(models.Model):
    portfolio = models.ForeignKey(
        StockPortfolio,
        on_delete=models.CASCADE,
        related_name='watchlist_stocks'
    )
    ticker = models.CharField(max_length=12)
    created_at = models.DateTimeField(default=timezone.now)


class BankAccount(models.Model):
    finance_profile = models.ForeignKey(
        FinanceProfile,
        on_delete=models.CASCADE,
        related_name='bank_accounts'
    )
    account_name = models.CharField(max_length=100)
    account_number = models.CharField(max_length=50)
    institution_name = models.CharField(max_length=100)
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    currency = models.CharField(max_length=10, default='USD')
    last_synced = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']


class Budget(models.Model):
    finance_profile = models.ForeignKey(
        FinanceProfile,
        on_delete=models.CASCADE,
        related_name='budgets'
    )
    name = models.CharField(max_length=100)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    start_date = models.DateField()
    end_date = models.DateField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def total_allocated(self):
        """
        Calculates the total allocated amount for all categories in this budget.
        """
        return self.categories.aggregate(total=Sum('allocated_amount'))['total'] or 0.00

    def total_spent(self):
        """
        Calculates the total spent amount (EXPENSE) against this budget.
        """
        return Transaction.objects.filter(
            finance_profile=self.finance_profile,
            budget_category__budget=self,
            transaction_type='EXPENSE'
        ).aggregate(total=Sum('amount'))['total'] or 0.00

    def remaining_budget(self):
        """
        Returns the remaining budget after subtracting total spent from total allocated.
        """
        return self.total_allocated() - self.total_spent()


class BudgetCategory(models.Model):
    budget = models.ForeignKey(
        Budget,
        on_delete=models.CASCADE,
        related_name='categories'
    )
    name = models.CharField(max_length=100)
    allocated_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    category_type = models.CharField(
        max_length=20,
        choices=CategoryType.choices,
        default=CategoryType.NECESSARY
    )

    class Meta:
        ordering = ['category_type', 'name']

    def total_spent(self):
        """
        Calculates the total amount spent (EXPENSE) within this budget category.
        """
        return self.transactions.filter(transaction_type='EXPENSE').aggregate(total=Sum('amount'))['total'] or 0.00

    def remaining_allocated_amount(self):
        """
        Returns the amount remaining out of the allocated amount after subtracting total spent.
        """
        return self.allocated_amount - self.total_spent()


class Transaction(models.Model):
    TRANSACTION_TYPES = (
        ('EXPENSE', 'Expense'),
        ('INCOME', 'Income'),
        ('TRANSFER', 'Transfer'),
    )
    finance_profile = models.ForeignKey(
        FinanceProfile,
        on_delete=models.CASCADE,
        related_name='transactions'
    )
    bank_account = models.ForeignKey(
        BankAccount,
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )
    budget_category = models.ForeignKey(
        BudgetCategory,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='transactions'
    )
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    description = models.TextField(null=True, blank=True)
    date = models.DateField(default=timezone.now)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.transaction_type} - {self.amount}'