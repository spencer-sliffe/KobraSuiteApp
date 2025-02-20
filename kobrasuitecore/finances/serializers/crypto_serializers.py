"""
------------------Prologue--------------------
File Name: crypto_serializers.py
Path: kobrasuitecore/finances/serializers/crypto_serializers.py

Description:
Provides serializers to handle data for crypto portfolios, individual crypto holdings,
and user favorites/watchlists. Ensures correct structure and validation for crypto-based
data.

Input:
Raw request data related to crypto portfolios and coins.

Output:
JSON representations of crypto portfolio objects, including nested relationships like
portfolio cryptos, favorites, and watchlist items.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import serializers
from finances.models import CryptoPortfolio, PortfolioCrypto, FavoriteCrypto, WatchlistCrypto


class PortfolioCryptoSerializer(serializers.ModelSerializer):
    class Meta:
        model = PortfolioCrypto
        fields = [
            'id',
            'crypto_id',
            'ticker',
            'number_of_units',
            'ppu_at_purchase',
            'created_at',
            'updated_at'
        ]


class CryptoPortfolioSerializer(serializers.ModelSerializer):
    cryptos = PortfolioCryptoSerializer(many=True, read_only=True)

    class Meta:
        model = CryptoPortfolio
        fields = [
            'id',
            'profile',
            'created_at',
            'updated_at',
            'cryptos'
        ]


class FavoriteCryptoSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoriteCrypto
        fields = [
            'id',
            'crypto_id',
            'ticker',
            'created_at'
        ]


class WatchlistCryptoSerializer(serializers.ModelSerializer):
    class Meta:
        model = WatchlistCrypto
        fields = [
            'id',
            'crypto_id',
            'ticker',
            'created_at'
        ]