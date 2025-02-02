# File: customer/views/auth_viewset.py
from django.db.utils import IntegrityError
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import get_user_model

from customer.serializers.auth_serializers import RegisterSerializer, LoginSerializer
from customer.serializers.user_serializers import UserSerializer
from customer.models import Role


class AuthViewSet(viewsets.GenericViewSet):
    queryset = Role.objects.all()

    def get_serializer_class(self):
        if self.action == 'register':
            return RegisterSerializer
        elif self.action == 'login':
            return LoginSerializer
        elif self.action == 'logout':
            return LoginSerializer
        elif self.action == 'whoami':
            return UserSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action in ['register', 'login']:
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
            'profile', 'school_profile', 'work_profile', 'finance_profile', 'homelife_profile'
        ).get(pk=request.user.pk)
        serializer = UserSerializer(user)
        return Response({"user": serializer.data}, status=status.HTTP_200_OK)