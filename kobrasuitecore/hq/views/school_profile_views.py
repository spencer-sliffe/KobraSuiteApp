# File: hq/views/school_profile_views.py
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from hq.models import UserProfile, SchoolProfile
from hq.serializers.school_profile_serializers import SchoolProfileSerializer
from school.models import University
from school.serializers.university_serializers import SetUniversitySerializer
from asgiref.sync import async_to_sync
from school.services.university_service import add_university_to_db

class SchoolProfileViewSet(viewsets.ModelViewSet):
    queryset = SchoolProfile.objects.select_related('profile__user', 'university').prefetch_related('courses')
    serializer_class = SchoolProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Nested route:
        /users/<user_pk>/profile/<profile_pk>/school_profile/<school_profile_pk>/
        """
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        return self.queryset.filter(
            profile__id=profile_pk,
            profile__user__id=user_pk
        )

    def perform_create(self, serializer):
        user_pk = self.kwargs.get('user_pk')
        profile_pk = self.kwargs.get('profile_pk')
        user_profile = get_object_or_404(UserProfile, pk=profile_pk, user__id=user_pk)
        serializer.save(profile=user_profile)

    def perform_update(self, serializer):
        instance = self.get_object()
        serializer.save(profile=instance.profile)

    @action(methods=['post'], detail=True, url_path='set_university')
    def set_university(self, request, user_pk=None, profile_pk=None, pk=None):
        """
        Example usage:
        POST /.../school_profile/<pk>/set_university/ 
        { "name": "Some University", "country": "US" }
        """
        school_profile = self.get_object()
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

        school_profile.university = university
        school_profile.save()

        return Response(self.get_serializer(school_profile).data, status=status.HTTP_200_OK)

    @action(methods=['delete'], detail=True, url_path='remove_university')
    def remove_university(self, request, user_pk=None, profile_pk=None, pk=None):
        school_profile = self.get_object()
        if not school_profile.university:
            return Response({"detail": "No university is set."}, status=status.HTTP_400_BAD_REQUEST)
        school_profile.university = None
        school_profile.save()

        return Response(self.get_serializer(school_profile).data, status=status.HTTP_200_OK)