"""
------------------Prologue--------------------
File Name: user_serializers.py
Path: kobrasuitecore/customer/serializers/user_serializers.py

Description:
Defines serializer classes that handle user data, including associated profile details
for school, work, finance, and homelife. Supports both retrieval and updates of nested
profile information.

Input:
User data and associated nested profile fields for validation and transformation.

Output:
JSON representations of user objects, including nested profile identifiers and content.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# File: customer/serializers/user_serializers.py
from rest_framework import serializers
from django.contrib.auth import get_user_model
from hq.models import UserProfile
from hq.serializers.user_profile_serializers import UserProfileSerializer

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number',
            'is_email_verified', 'is_phone_verified',
            'profile'
        ]
        read_only_fields = ['is_email_verified', 'is_phone_verified']

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', None)
        user = super().update(instance, validated_data)
        if profile_data:
            profile_instance = getattr(user, 'profile', None)
            if not profile_instance:
                profile_instance = UserProfile.objects.create(user=user)
            for attr, value in profile_data.items():
                setattr(profile_instance, attr, value)
            profile_instance.save()
        return user