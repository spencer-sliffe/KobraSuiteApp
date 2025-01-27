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