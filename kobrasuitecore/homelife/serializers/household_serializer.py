from rest_framework import serializers
from homelife.models import Household


class HouseholdSerializer(serializers.ModelSerializer):
    class Meta:
        model = Household
        fields = ('id', 'name', 'household_type', 'join_code', 'created_at', 'updated_at')
        extra_kwargs = {
            'join_code': {
                'write_only': False,  # let creators POST it *and* everyone GET it
                'required': True,
            }
        }
