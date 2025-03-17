"""
------------------Prologue--------------------
File Name: stock_utils.py
Path: kobrasuitecore\finances\utils\stock_utils.py

Description:
Structures and creates Django Models to be used within the Finance module
Input:
N/A

Output:
Django Models

Collaborators: SPENCER SLIFFE,Charlie Gillund
---------------------------------------------
"""
from django.db import models
from django.utils import timezone
from hq.models import FinanceProfile
from .types import CategoryType

# Defines Stock Portfolio Model
class StockPortfolio(models.Model):
    profile = models.ForeignKey(FinanceProfile, on_delete=models.CASCADE, related_name='stock_portfolios')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

# Defines Portfolio Stock Model
class PortfolioStock(models.Model):
    portfolio = models.ForeignKey(StockPortfolio, on_delete=models.CASCADE, related_name='stocks')
    ticker = models.CharField(max_length=12)
    number_of_shares = models.IntegerField()
    pps_at_purchase = models.FloatField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

# Defines Watchlist Stock Model
class WatchlistStock(models.Model):
    portfolio = models.ForeignKey(StockPortfolio, on_delete=models.CASCADE, related_name='watchlist_stocks')
    ticker = models.CharField(max_length=12)
    created_at = models.DateTimeField(default=timezone.now)

# Defines Bank Account Model

class BankAccount(models.Model):
    profile = models.ForeignKey(
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
# Meta data needed for model
    class Meta:
        ordering = ['-created_at']

# Defines Budget Model

class Budget(models.Model):
    profile = models.ForeignKey(
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
# function to calulate budget allocation 
    def total_allocated(self):
        return self.categories.aggregate(total=models.Sum('allocated_amount'))['total'] or 0.00
# function to caluclate total spent
    def total_spent(self):
        from .models import Transaction
        return Transaction.objects.filter(
            profile=self.profile,
            budget_category__budget=self,
            transaction_type='EXPENSE'
        ).aggregate(total=models.Sum('amount'))['total'] or 0.00
# function to check remaining balance 
    def remaining_budget(self):
        return self.total_allocated() - self.total_spent()

# Defines Budget Catergories Model

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
# Stores Meta data fro model
    class Meta:
        ordering = ['category_type', 'name']
# Function to calculate total spent
    def total_spent(self):
        return self.transactions.filter(transaction_type='EXPENSE').aggregate(total=models.Sum('amount'))['total'] or 0.00
# Function to calculate remaining Allocation

    def remaining_allocated_amount(self):
        return self.allocated_amount - self.total_spent()

# Defines Transaction Model
class Transaction(models.Model):
    TRANSACTION_TYPES = (
        ('EXPENSE', 'Expense'),
        ('INCOME', 'Income'),
        ('TRANSFER', 'Transfer'),
    )
    profile = models.ForeignKey(
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
# defines meta data fro transactiosn
    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.transaction_type} - {self.amount}' # String format for transactiosn 
    