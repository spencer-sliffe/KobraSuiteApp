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
from ..models import Role

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=False)
    school_profile = serializers.SerializerMethodField()
    work_profile = serializers.SerializerMethodField()
    finance_profile = serializers.SerializerMethodField()
    homelife_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number',
            'is_email_verified', 'is_phone_verified',
            'profile', 'school_profile', 'work_profile', 'finance_profile', 'homelife_profile',
        ]
        read_only_fields = ['is_email_verified', 'is_phone_verified']

    def get_school_profile(self, obj):
        if hasattr(obj, 'school_profile') and obj.school_profile is not None:
            return {'id': obj.school_profile.id}
        return None

    def get_work_profile(self, obj):
        if hasattr(obj, 'work_profile') and obj.work_profile is not None:
            return {'id': obj.work_profile.id}
        return None

    def get_finance_profile(self, obj):
        if hasattr(obj, 'finance_profile') and obj.finance_profile is not None:
            return {'id': obj.finance_profile.id}
        return None

    def get_homelife_profile(self, obj):
        if hasattr(obj, 'homelife_profile') and obj.homelife_profile is not None:
            return {'id': obj.homelife_profile.id}
        return None

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