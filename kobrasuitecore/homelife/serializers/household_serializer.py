from rest_framework import serializers
from school.models import Course


class HouseholdSerializer(serializers.ModelSerializer):
    member_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Course
        fields = [
            'name', 'id', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_household(self, obj):
        if obj.household:
            return {
                "id": obj.household.id,
                "name": obj.household.name,
            }
        return None

    def create_household(self, obj):
        return


class HouseholdProfileActionSerializer(serializers.Serializer):
    household_id = serializers.IntegerField()