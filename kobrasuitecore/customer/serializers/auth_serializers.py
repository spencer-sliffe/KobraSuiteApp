"""
------------------Prologue--------------------
File Name: auth_serializers.py
Path: kobrasuitecore/customer/serializers/auth_serializers.py

Description:
Provides serialization logic for user registration and login, including JWT token handling
and password validation.

Input:
User registration details and login credentials.

Output:
Validated user data, JWT tokens, and error messages for authentication flows.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""

from django.contrib.auth import get_user_model, authenticate
from django.contrib.auth.password_validation import validate_password

from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from customer.serializers.user_serializers import UserSerializer

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)

    class Meta:
        model = User
        fields = [
            'username',
            'email',
            'phone_number',
            'password',
            'confirm_password',
            'access',
            'refresh',
        ]
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({"password": "Passwords do not match."})
        validate_password(attrs['password'], self.instance)
        return attrs

    def create(self, validated_data):
        validated_data.pop('confirm_password', None)
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()

        refresh = RefreshToken.for_user(user)
        return {
            'user': user,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }

    def to_representation(self, instance):
        user = instance['user']
        access = instance['access']
        refresh = instance['refresh']
        user_data = UserSerializer(user).data

        return {
            'user': user_data,
            'access': access,
            'refresh': refresh,
        }


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(style={"input_type": "password"}, write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)

    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')

        if not username or not password:
            raise serializers.ValidationError("Must include username and password.")

        user = authenticate(username=username, password=password)
        if not user:
            raise serializers.ValidationError("Invalid credentials.")

        if not user.is_active:
            raise serializers.ValidationError("User account is disabled.")

        refresh = RefreshToken.for_user(user)
        attrs['user'] = user
        attrs['access'] = str(refresh.access_token)
        attrs['refresh'] = str(refresh)

        return attrs

    def to_representation(self, instance):
        user = instance['user']
        access = instance['access']
        refresh = instance['refresh']
        user_data = UserSerializer(user).data

        return {
            'user': user_data,
            'access': access,
            'refresh': refresh,
        }