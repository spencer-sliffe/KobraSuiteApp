from rest_framework import serializers

from hq.models import FinanceProfile


class FinanceProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = FinanceProfile
        fields = [
            'id',

        ]
