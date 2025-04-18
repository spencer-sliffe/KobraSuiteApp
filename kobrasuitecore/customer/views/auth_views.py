"""
------------------Prologue--------------------
File Name: auth_viewset.py
Path: kobrasuitecore/customer/views/auth_viewset.py

Description:
Exposes endpoints for registering new users, logging in, logging out, and retrieving user
information (whoami). Utilizes DRF and JWT for managing authentication tokens.

Input:
Registration and login data, refresh tokens for logout, and user credentials.

Output:
JWT tokens, success messages, user data, or error details.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# File: customer/views/auth_viewset.py
from django.db.utils import IntegrityError
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import get_user_model

from customer.serializers.auth_serializers import RegisterSerializer, LoginSerializer, PasswordResetRequestSerializer, \
    PasswordResetConfirmSerializer
from customer.serializers.user_serializers import UserSerializer
from customer.models import Role


class AuthViewSet(viewsets.GenericViewSet):
    def get_serializer_class(self):
        if self.action == 'register':
            return RegisterSerializer
        elif self.action == 'login':
            return LoginSerializer
        elif self.action == 'logout':
            return LoginSerializer
        elif self.action == 'whoami':
            return UserSerializer
        if self.action == 'password_reset':
            return PasswordResetRequestSerializer
        if self.action == 'password_reset_confirm':
            return PasswordResetConfirmSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action in ['register', 'login', 'password_reset', 'password_reset_confirm']:
            self.permission_classes = [AllowAny]
        elif self.action in ['logout', 'whoami']:
            self.permission_classes = [IsAuthenticated]
        else:
            self.permission_classes = [IsAuthenticated]
        return super().get_permissions()

    @action(methods=['post'], detail=False)
    def register(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            try:
                result = serializer.save()
            except IntegrityError:
                return Response(
                    {"success": False, "errors": "Username or email already taken."},
                    status=status.HTTP_409_CONFLICT
                )
            return Response(
                {
                    "success": True,
                    "message": "User registered successfully.",
                    **serializer.data
                },
                status=status.HTTP_201_CREATED
            )
        return Response(
            {"success": False, "errors": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )

    @action(methods=['post'], detail=False)
    def login(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            return Response(
                {
                    "success": True,
                    "message": "Logged in successfully.",
                    **serializer.data
                },
                status=status.HTTP_200_OK
            )
        else:
            errors = serializer.errors
            invalid_credentials = 'Invalid credentials.' in str(errors)
            return Response(
                {"success": False, "errors": errors},
                status=status.HTTP_401_UNAUTHORIZED if invalid_credentials else status.HTTP_400_BAD_REQUEST
            )

    @action(methods=['post'], detail=False)
    def logout(self, request):
        refresh_token = request.data.get("refresh")
        if not refresh_token:
            return Response(
                {"success": False, "errors": "Refresh token is required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response(
                {"success": True, "message": "Logged out successfully."},
                status=status.HTTP_200_OK
            )
        except TokenError:
            return Response(
                {"success": False, "errors": "Invalid or expired refresh token."},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(methods=['get'], detail=False)
    def whoami(self, request):
        User = get_user_model()
        user = User.objects.select_related(
            'profile'
        ).get(pk=request.user.pk)
        serializer = UserSerializer(user)
        return Response({"user": serializer.data}, status=status.HTTP_200_OK)

    @action(methods=['post'], detail=False)
    def password_reset(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.send_password_reset_email()
            return Response({"success": True, "message": "Password reset email sent."}, status=status.HTTP_200_OK)
        return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    @action(methods=['post'], detail=False)
    def password_reset_confirm(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"success": True, "message": "Password has been reset."}, status=status.HTTP_200_OK)
        return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)