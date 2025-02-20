"""
------------------Prologue--------------------
File Name: stock_serializers.py
Path: kobrasuitecore/finances/serializers/stock_serializers.py

Description:
Contains serializer classes for the stock-related data models, including stock portfolios,
individual holdings, and favorites/watchlists. Validates and structures data for storage
and retrieval.

Input:
Incoming stock data such as ticker symbols, purchase info, and portfolio references.

Output:
Validated JSON structures representing stocks, portfolios, and watchlist/favorites entries.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import serializers
from finances.models import StockPortfolio, PortfolioStock, FavoriteStock, WatchlistStock


class PortfolioStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = PortfolioStock
        fields = [
            'id',
            'ticker',
            'number_of_shares',
            'pps_at_purchase',
            'created_at',
            'updated_at'
        ]


class StockPortfolioSerializer(serializers.ModelSerializer):
    stocks = PortfolioStockSerializer(many=True, read_only=True)

    class Meta:
        model = StockPortfolio
        fields = [
            'id',
            'profile',
            'created_at',
            'updated_at',
            'stocks'
        ]


class FavoriteStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoriteStock
        fields = [
            'id',
            'ticker',
            'created_at'
        ]


class WatchlistStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = WatchlistStock
        fields = [
            'id',
            'ticker',
            'created_at'
        ]