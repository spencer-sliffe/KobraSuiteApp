from rest_framework import serializers
from finances.models import StockPortfolio, PortfolioStock, WatchlistStock


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


class WatchlistStockSerializer(serializers.ModelSerializer):
    class Meta:
        model = WatchlistStock
        fields = [
            'id',
            'ticker',
            'created_at'
        ]