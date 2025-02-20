from django.contrib import admin
from .models import (
    StockPortfolio, PortfolioStock, FavoriteStock, WatchlistStock,
    CryptoPortfolio, PortfolioCrypto, FavoriteCrypto, WatchlistCrypto,
    Budget, BudgetCategory, Transaction, BankAccount
)

@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'total_amount', 'start_date', 'end_date', 'is_active')
    list_filter = ('is_active', 'start_date', 'end_date')
    search_fields = ('name', 'user__username')

@admin.register(BudgetCategory)
class BudgetCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'budget', 'category_type', 'allocated_amount')
    list_filter = ('category_type', 'budget')
    search_fields = ('name', 'budget__name')

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_type', 'amount', 'user', 'budget_category', 'date', 'created_at')
    list_filter = ('transaction_type', 'budget_category__category_type', 'date')
    search_fields = ('description', 'user__username', 'budget_category__name')

@admin.register(StockPortfolio)
class StockPortfolioAdmin(admin.ModelAdmin):
    list_display = ('profile', 'created_at', 'updated_at')
    search_fields = ('profile__user__username',)

@admin.register(PortfolioStock)
class PortfolioStockAdmin(admin.ModelAdmin):
    list_display = ('portfolio', 'ticker', 'number_of_shares', 'pps_at_purchase', 'created_at', 'updated_at')
    search_fields = ('ticker', 'portfolio__profile__user__username')



@admin.register(WatchlistStock)
class WatchlistStockAdmin(admin.ModelAdmin):
    list_display = ('portfolio', 'ticker', 'created_at')
    search_fields = ('ticker', 'portfolio__profile__user__username')




@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = ('account_name', 'user', 'institution_name', 'balance', 'currency', 'last_synced', 'created_at', 'updated_at')
    search_fields = ('account_name', 'user__username', 'institution_name')
    list_filter = ('currency', 'institution_name')