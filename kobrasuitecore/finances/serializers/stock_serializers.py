# """
# ------------------Prologue--------------------
# File Name: stock_serializer.py
# Path: kobrasuitecore\finances\serializers\stock_serializer.py
#
# Description:
# Converts Django models into JSON for a sendable format.
#
# Input:
# Django models
#
# Output:
# JSON representations of Django models
#
# Collaborators: SPENCER SLIFFE, Charlie Gillund
# ---------------------------------------------
# """

from rest_framework import serializers
from finances.models import StockPortfolio, PortfolioStock, WatchlistStock


class PortfolioStockSerializer(serializers.ModelSerializer):
    """
    Serializer for PortfolioStock model.
    """
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
    """
    Serializer for StockPortfolio model, including read-only
    PortfolioStock data.
    """
    stocks = PortfolioStockSerializer(many=True, read_only=True)

    class Meta:
        model = StockPortfolio
        fields = [
            'id',
            'finance_profile',
            'created_at',
            'updated_at',
            'stocks'
        ]


class WatchlistStockSerializer(serializers.ModelSerializer):
    """
    Serializer for WatchlistStock model.
    """
    class Meta:
        model = WatchlistStock
        fields = [
            'id',
            'ticker',
            'created_at'
        ]