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
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail

from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from customer.serializers.user_serializers import UserSerializer
from kobrasuitecore import settings

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


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError('No account found with this email.')
        return value

    def send_password_reset_email(self):
        email = self.validated_data['email']
        user = User.objects.filter(email=email).first()
        token = default_token_generator.make_token(user)
        reset_url = f"{settings.BASE_URL}/api/auth/password_reset_confirm/?uid={user.pk}&token={token}"
        send_mail(
            'Password Reset Request',
            f"Visit the following link to reset your password: {reset_url}",
            settings.DEFAULT_FROM_EMAIL,
            [email],
            fail_silently=False,
        )


class PasswordResetConfirmSerializer(serializers.Serializer):
    uid = serializers.CharField()
    token = serializers.CharField()
    new_password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        uid = attrs.get('uid')
        token = attrs.get('token')
        new_password = attrs.get('new_password')
        try:
            user = User.objects.get(pk=uid)
        except User.DoesNotExist:
            raise serializers.ValidationError('Invalid user.')

        if not default_token_generator.check_token(user, token):
            raise serializers.ValidationError('Invalid or expired token.')
        attrs['user'] = user
        attrs['new_password'] = new_password
        return attrs

    def save(self):
        user = self.validated_data['user']
        new_password = self.validated_data['new_password']
        user.set_password(new_password)
        user.save()
        return user