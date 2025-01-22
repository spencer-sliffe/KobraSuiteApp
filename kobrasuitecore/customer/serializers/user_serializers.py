# customer/serializers/user_serializers.py

from rest_framework import serializers
from django.contrib.auth import get_user_model

from .profile_serializers import UserProfileSerializer, SchoolProfileSerializer
from ..models import Role, UserProfile, SchoolProfile

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(required=False)
    school_profile = SchoolProfileSerializer(required=False)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'phone_number',
            'is_email_verified', 'is_phone_verified',
            'profile', 'school_profile',
        ]
        read_only_fields = ['is_email_verified', 'is_phone_verified']

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', None)
        school_profile_data = validated_data.pop('school_profile', None)
        user = super().update(instance, validated_data)

        if profile_data:
            profile_instance = getattr(user, 'profile', None)
            if not profile_instance:
                profile_instance = UserProfile.objects.create(user=user)
            for attr, value in profile_data.items():
                setattr(profile_instance, attr, value)
            profile_instance.save()

        if school_profile_data:
            school_profile_instance = getattr(user, 'school_profile', None)
            if not school_profile_instance:
                school_profile_instance = SchoolProfile.objects.create(user=user)
            for attr, value in school_profile_data.items():
                setattr(school_profile_instance, attr, value)
            if 'courses' in school_profile_data:
                courses = school_profile_data.pop('courses')
                school_profile_instance.courses.set(courses)
            school_profile_instance.save()

        return user


class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = '__all__'
