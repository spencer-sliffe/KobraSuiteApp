from rest_framework import serializers

from hq.models import FinanceProfile


class FinanceProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = FinanceProfile
        fields = [
            'id',
            'budget',
            'default_stock_portfolio',
            'default_crypto_portfolio'
        ]
