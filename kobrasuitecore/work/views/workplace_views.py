"""
------------------Prologue--------------------
File Name: workplace_views.py
Path: kobrasuitecore/work/views/workplace_views.py

Description:
Implements API endpoints for managing workplaces.
Provides actions for creating a workplace, joining/leaving a workplace, and listing workplace members.
Handles permissions and ownership validations while integrating with filtering mechanisms.

Input:
HTTP requests for workplace management and membership operations.

Output:
Serialized workplace data, success messages, and error responses related to workplace operations.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from drf_spectacular.utils import extend_schema
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend

from work.models import WorkPlace
from work.serializers.workplace_serializers import WorkPlaceSerializer
from customer.permissions import IsOwnerOrAdmin
from work.filters import WorkplaceMemberFilter
from hq.models import WorkProfile
from customer.models import User


@extend_schema(
    tags=["workplace"],
)
class WorkPlaceViewSet(viewsets.ModelViewSet):
    queryset = WorkPlace.objects.all()
    serializer_class = WorkPlaceSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.owner != request.user and not request.user.is_staff and not request.user.is_superuser:
            return Response({"detail": "Not allowed."}, status=status.HTTP_403_FORBIDDEN)
        return super().destroy(request, *args, **kwargs)

    @action(methods=['post'], detail=False, url_path='join', permission_classes=[IsAuthenticated])
    def join_workplace(self, request):
        code = request.data.get('invite_code')
        if not code:
            return Response({"detail": "No invite code provided."}, status=status.HTTP_400_BAD_REQUEST)
        workplace = WorkPlace.objects.filter(invite_code=code).first()
        if not workplace:
            return Response({"detail": "Invalid invite code."}, status=status.HTTP_404_NOT_FOUND)
        profile = request.user.profile.work_profile
        profile.work_places.add(workplace)
        return Response({"detail": "Joined workplace."}, status=status.HTTP_200_OK)

    @action(methods=['post'], detail=True, url_path='leave', permission_classes=[IsAuthenticated])
    def leave_workplace(self, request, pk=None):
        workplace = self.get_object()
        profile = request.user.profile.work_profile
        if not profile.work_places.filter(id=workplace.id).exists():
            return Response({"detail": "Not a member of this workplace."}, status=status.HTTP_400_BAD_REQUEST)
        if workplace.owner == request.user:
            other_profiles = WorkProfile.objects.filter(work_places=workplace).exclude(user=request.user)
            if other_profiles.exists():
                new_owner_profile = other_profiles.first()
                workplace.owner = new_owner_profile.user
                workplace.save()
            else:
                workplace.delete()
                return Response({"detail": "Workplace deleted as owner left with no other members."}, status=status.HTTP_200_OK)
        profile.work_places.remove(workplace)
        return Response({"detail": "Left workplace."}, status=status.HTTP_200_OK)

    @action(methods=['get'], detail=True, url_path='members', permission_classes=[IsAuthenticated])
    def list_members(self, request, pk=None):
        workplace = self.get_object()
        profiles = WorkProfile.objects.filter(work_places=workplace)
        filter_backend = DjangoFilterBackend()
        queryset = User.objects.filter(work_profile__in=profiles)
        filtered_queryset = filter_backend.filter_queryset(request, queryset, self)
        member_filter = WorkplaceMemberFilter(request.GET, queryset=filtered_queryset)
        final_queryset = member_filter.qs
        serializer_data = []
        for user_obj in final_queryset:
            serializer_data.append({
                "id": user_obj.id,
                "username": user_obj.username,
                "email": user_obj.email
            })
        return Response({"members": serializer_data}, status=status.HTTP_200_OK)