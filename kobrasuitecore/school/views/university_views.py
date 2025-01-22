# school/views/university_views.py
import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination

from ..filters import UniversityFilter
from ..models import University
from ..serializers.university_serializers import UniversitySerializer
from ..services.university_service import search_universities
from customer.permissions import IsAdminOrReadOnly

logger = logging.getLogger(__name__)


class UniversityViewSet(viewsets.ModelViewSet):
    queryset = University.objects.all()
    serializer_class = UniversitySerializer
    permission_classes = [IsAuthenticated, IsAdminOrReadOnly]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = UniversityFilter
    ordering_fields = ['name', 'country']
    ordering = ['name']

    def perform_create(self, serializer):
        university = serializer.save()
        logger.info(f"University created: {university.name} by {self.request.user.username}")

    @action(detail=False, methods=['get'], url_path='search', name='search_university')
    def search_university(self, request, user_pk=None, school_profile_pk=None):
        query = request.query_params.get('query', '')
        country = request.query_params.get('country', None)
        data, code = search_universities(query, country)
        return Response(data, status=code)