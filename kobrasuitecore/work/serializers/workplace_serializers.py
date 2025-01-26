from rest_framework import serializers
from work.models import WorkPlace
from customer.serializers.user_serializers import UserSerializer


class WorkPlaceSerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)
    member_count = serializers.ReadOnlyField()

    class Meta:
        model = WorkPlace
        fields = ['id', 'name', 'field', 'website', 'invite_code', 'owner', 'identity_image', 'created_at', 'member_count']