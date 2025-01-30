# customer/views.py
from django.contrib.auth import get_user_model
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404


from hq.models import SchoolProfile, WorkProfile, FinanceProfile
from hq.serializers.profile_serializers import SchoolProfileSerializer, WorkProfileSerializer, FinanceProfileSerializer
from school.models import University
from school.serializers.university_serializers import SetUniversitySerializer
from asgiref.sync import async_to_sync
from school.services.university_service import add_university_to_db

from customer.permissions import IsOwnerOrAdmin


class SchoolProfileViewSet(viewsets.ModelViewSet):
    queryset = SchoolProfile.objects.all().select_related('university').prefetch_related('courses')
    serializer_class = SchoolProfileSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        return self.queryset.filter(user__id=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        user = get_object_or_404(get_user_model(), pk=user_pk)
        serializer.save(user=user)

    @action(methods=['post'], detail=True, url_path='set_university', permission_classes=[IsAuthenticated])
    def set_university(self, request, user_pk=None, pk=None):
        profile = self.get_object()
        serializer = SetUniversitySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        name = serializer.validated_data.get('name').strip()
        country = serializer.validated_data.get('country').strip()
        domain = serializer.validated_data.get('domain', '').strip()
        website = serializer.validated_data.get('website', '').strip()

        university = University.objects.filter(
            name__iexact=name,
            country__iexact=country,
            domain__iexact=domain
        ).first()

        if not university:
            try:
                university = async_to_sync(add_university_to_db)(name, country)
            except ValueError as e:
                return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        profile.university = university
        profile.save()

        profile_serializer = self.get_serializer(profile)
        return Response(profile_serializer.data, status=status.HTTP_200_OK)

    @action(methods=['delete'], detail=True, url_path='remove_university', permission_classes=[IsAuthenticated])
    def remove_university(self, request, user_pk=None):
        profile = self.get_object()
        if not profile.university:
            return Response({"detail": "No university is set."}, status=status.HTTP_400_BAD_REQUEST)

        profile.university = None
        profile.save()

        profile_serializer = self.get_serializer(profile)
        return Response(profile_serializer.data, status=status.HTTP_200_OK)


class WorkProfileViewSet(viewsets.ModelViewSet):
    queryset = WorkProfile.objects.all()
    serializer_class = WorkProfileSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        return self.queryset.filter(user__id=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        user = get_object_or_404(get_user_model(), pk=user_pk)
        serializer.save(user=user)

    def perform_update(self, serializer):
        serializer.save(user=self.get_object().user)


class FinanceProfileViewSet(viewsets.ModelViewSet):
    queryset = FinanceProfile.objects.all()
    serializer_class = FinanceProfileSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        return self.queryset.filter(user__id=user_pk)

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        user = get_object_or_404(get_user_model(), pk=user_pk)
        serializer.save(user=user)

    def perform_update(self, serializer):
        serializer.save(user=self.get_object().user)