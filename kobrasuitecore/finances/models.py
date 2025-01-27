
"""
------------------Prologue--------------------
File Name: models.py
Path: kobrasuitecore/finances/models.py

Description:
Defines the data models for the application, including StockPortfolio, PortfolioStock, FavoriteStock, WatchedStock
Defines the data models for the application, CryptoPortfolio, PortfolioCrypto, FavoriteCrypto, WatchedPortfolio

Input:
None directly; models are populated and queried by other application components

Output:
Database table representations for StockPortfolio, PortfolioStock, FavoriteStock, WatchedStock
Database table representations for CryptoPortfolio, PortfolioCrypto, FavoriteCrypto, WatchedPortfolio

Collaborators: Spencer Sliffe
---------------------------------------------
"""

from django.db import models
from django.utils import timezone
from customer.models import FinanceProfile


class StockPortfolio(models.Model):
    profile = models.ForeignKey(FinanceProfile, on_delete=models.CASCADE, related_name='stock_portfolios')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class PortfolioStock(models.Model):
    portfolio = models.ForeignKey(StockPortfolio, on_delete=models.CASCADE, related_name='stocks')
    ticker = models.CharField(max_length=12)
    number_of_shares = models.IntegerField()
    pps_at_purchase = models.FloatField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class FavoriteStock(models.Model):
    portfolio = models.ForeignKey(StockPortfolio, on_delete=models.CASCADE, related_name='favorite_stocks')
    ticker = models.CharField(max_length=12)
    created_at = models.DateTimeField(default=timezone.now)


class WatchlistStock(models.Model):
    portfolio = models.ForeignKey(StockPortfolio, on_delete=models.CASCADE, related_name='watchlist_stocks')
    ticker = models.CharField(max_length=12)
    created_at = models.DateTimeField(default=timezone.now)


class CryptoPortfolio(models.Model):
    profile = models.ForeignKey(FinanceProfile, on_delete=models.CASCADE, related_name='crypto_portfolios')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class PortfolioCrypto(models.Model):
    portfolio = models.ForeignKey(CryptoPortfolio, on_delete=models.CASCADE, related_name='cryptos')
    crypto_id = models.CharField(max_length=30)
    ticker = models.CharField(max_length=15)
    number_of_units = models.FloatField()
    ppu_at_purchase = models.FloatField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)


class FavoriteCrypto(models.Model):
    portfolio = models.ForeignKey(CryptoPortfolio, on_delete=models.CASCADE, related_name='favorite_cryptos')
    crypto_id = models.CharField(max_length=30)
    ticker = models.CharField(max_length=15)
    created_at = models.DateTimeField(default=timezone.now)


class WatchlistCrypto(models.Model):
    portfolio = models.ForeignKey(CryptoPortfolio, on_delete=models.CASCADE, related_name='watchlist_cryptos')
    crypto_id = models.CharField(max_length=30)
    ticker = models.CharField(max_length=15)
    created_at = models.DateTimeField(default=timezone.now)

# class BankAccount(models.Model):
#     """
#     Links a user to external or internal bank accounts.
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='bank_accounts'
#     )
#     account_name = models.CharField(max_length=100)
#     account_number = models.CharField(max_length=50)
#     institution_name = models.CharField(max_length=100)
#     balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
#     currency = models.CharField(max_length=10, default='USD')
#     last_synced = models.DateTimeField(null=True, blank=True)
#
#     created_at = models.DateTimeField(default=timezone.now)
#     updated_at = models.DateTimeField(auto_now=True)
#
#     def __str__(self):
#         return f"{self.account_name} - {self.user.username}"
#
#     class Meta:
#         ordering = ['-created_at']
#
#
# class Budget(models.Model):
#     """
#     Represents a user’s budget.
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='budgets'
#     )
#     name = models.CharField(max_length=100)
#     total_amount = models.DecimalField(max_digits=12, decimal_places=2)
#     start_date = models.DateField()
#     end_date = models.DateField()
#     is_active = models.BooleanField(default=True)
#
#     created_at = models.DateTimeField(default=timezone.now)
#     updated_at = models.DateTimeField(auto_now=True)
#
#     def __str__(self):
#         return f"{self.name} - {self.user.username}"
#
#     class Meta:
#         ordering = ['-created_at']
#
#
# class BudgetCategory(models.Model):
#     """
#     Sub-category within a Budget (e.g. 'Groceries', 'Rent').
#     """
#     budget = models.ForeignKey(
#         Budget,
#         on_delete=models.CASCADE,
#         related_name='categories'
#     )
#     name = models.CharField(max_length=100)
#     allocated_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
#
#     def __str__(self):
#         return f"{self.name} under {self.budget.name}"
#
#     class Meta:
#         ordering = ['name']
#
#
# class Transaction(models.Model):
#     """
#     Stores financial transactions (expenses, income, transfers).
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='transactions'
#     )
#     bank_account = models.ForeignKey(
#         BankAccount,
#         on_delete=models.CASCADE,
#         null=True,
#         blank=True
#     )
#     budget_category = models.ForeignKey(
#         BudgetCategory,
#         on_delete=models.SET_NULL,
#         null=True,
#         blank=True
#     )
#     transaction_type = models.CharField(
#         max_length=50,
#         choices=TransactionType.choices
#     )
#     amount = models.DecimalField(max_digits=12, decimal_places=2)
#     description = models.TextField(null=True, blank=True)
#     date = models.DateField()
#     created_at = models.DateTimeField(default=timezone.now)
#
#     def __str__(self):
#         return f"{self.transaction_type} - {self.amount} - {self.user.username}"
#
#     class Meta:
#         ordering = ['-created_at']
#
#
# class Bill(models.Model):
#     """
#     Recurring or one-time bills (utilities, subscriptions, etc.).
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='bills'
#     )
#     name = models.CharField(max_length=100)
#     amount = models.DecimalField(max_digits=12, decimal_places=2)
#     due_date = models.DateField()
#     recurring_interval = models.CharField(
#         max_length=50,
#         choices=RecurringInterval.choices,
#         default=RecurringInterval.NONE
#     )
#     is_auto_pay_enabled = models.BooleanField(default=False)
#
#     created_at = models.DateTimeField(default=timezone.now)
#     updated_at = models.DateTimeField(auto_now=True)
#
#     def __str__(self):
#         return f"{self.name} - {self.user.username}"
#
#     class Meta:
#         ordering = ['due_date']
#
#
# class Debt(models.Model):
#     """
#     Tracks loans, credit card balances, mortgages, etc.
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='debts'
#     )
#     name = models.CharField(max_length=100)
#     principal_amount = models.DecimalField(max_digits=12, decimal_places=2)
#     remaining_balance = models.DecimalField(max_digits=12, decimal_places=2)
#     interest_rate = models.DecimalField(max_digits=5, decimal_places=2)
#     due_date = models.DateField(null=True, blank=True)
#     debt_type = models.CharField(
#         max_length=50,
#         choices=DebtType.choices,
#         default=DebtType.OTHER
#     )
#     created_at = models.DateTimeField(default=timezone.now)
#
#     def __str__(self):
#         return f"{self.name} - {self.user.username}"
#
#     class Meta:
#         ordering = ['-created_at']
#
#
# class SavingsGoal(models.Model):
#     """
#     Goal-based savings (e.g., vacation fund).
#     """
#     user = models.ForeignKey(
#         settings.AUTH_USER_MODEL,
#         on_delete=models.CASCADE,
#         related_name='savings_goals'
#     )
#     name = models.CharField(max_length=100)
#     target_amount = models.DecimalField(max_digits=12, decimal_places=2)
#     current_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
#     deadline = models.DateField(null=True, blank=True)
#     created_at = models.DateTimeField(default=timezone.now)
#
#     def __str__(self):
#         return f"{self.name} - {self.user.username}"
#
#     class Meta:
#         ordering = ['-created_at']