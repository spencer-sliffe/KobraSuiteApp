# """
# ------------------Prologue--------------------
# File Name: stock_serializer.py
# Path: kobrasuitecore\finances\serializers\banking_serializers.py
#
# Description:
# Converts Django models into JSON for sendable format
#
# Input:
# Django models
#
# Output:
# JSON representation of Django Models
#
# Collaborators: SPENCER SLIFFE,Charlie Gillund
# ---------------------------------------------
# """
from rest_framework import serializers
from finances.models import StockPortfolio, PortfolioStock, WatchlistStock

# Serializer for the Portfolio stock
class PortfolioStockSerializer(serializers.ModelSerializer):
#defines the structure for the serializer
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

#declares the serializer for the Portfolio of Stokc
class StockPortfolioSerializer(serializers.ModelSerializer):
    stocks = PortfolioStockSerializer(many=True, read_only=True)
# defines the structure for the serializer
    class Meta:
        model = StockPortfolio
        fields = [
            'id',
            'profile',
            'created_at',
            'updated_at',
            'stocks'
        ]

# Defines the Watchlist Serialzier and its structure
class WatchlistStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = WatchlistStock
        fields = [
            'id',
            'ticker',
            'created_at'
        ]