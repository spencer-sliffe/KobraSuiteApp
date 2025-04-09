import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from rest_framework.pagination import PageNumberPagination

from finances.utils.stock_utils import get_news_articles
from kobrasuitecore import settings
from ..filters import UniversityFilter
from ..models import University
from ..serializers.university_serializers import UniversitySerializer
from ..services.university_service import search_universities
from customer.permissions import IsAdminOrReadOnly

logger = logging.getLogger(__name__)


class UniversityViewSet(viewsets.ModelViewSet):
    """
    Provides create/read/update/delete (CRUD) for University objects.
    If nested under user/school, you could optionally filter by
    user_pk / school_profile_pk in get_queryset(). By default, it retrieves all.
    """
    queryset = University.objects.all()
    serializer_class = UniversitySerializer
    permission_classes = [IsAuthenticated, IsAdminOrReadOnly]
    pagination_class = PageNumberPagination
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = UniversityFilter
    ordering_fields = ['name', 'country']
    ordering = ['name']

    def perform_create(self, serializer):
        """
        Logs a message whenever a University is created.
        """
        university = serializer.save()
        logger.info(f"University created: {university.name} by {self.request.user.username}")

    @action(detail=False, methods=['get'], url_path='search', name='search_university')
    def search_university(self, request, user_pk=None, profile_pk=None, school_profile_pk=None):
        """
        Searches universities by name/country using the external Hipolabs API,
        returns a list of known or potential matches.
        """
        query = request.query_params.get('query', '')
        if query not in ['U', 'u', 'Un', 'un', 'Uni', 'uni', 'Univ', 'univ','Unive', 'unive', 'Univers', 'univers' 
                    'Universi', 'universi' 'Universit','universit', 'University', 'university']:
            country = request.query_params.get('country')
            data, code = search_universities(query, country)
            return Response(data, status=code)

    @action(detail=True, methods=['get'], url_path='news', name='university_news')
    def university_news(self, request, user_pk=None, profile_pk=None, school_profile_pk=None, pk=None):
        """
        GET /api/users/<user_pk>/profile/<profile_pk>/school_profile/<school_profile_pk>/universities/<pk>/news
        Example: ?universityName=Stanford%20University
        """
        university = self.get_object()
        page = request.query_params.get('page', 1)
        # Pull 'universityName' if it exists, else fall back to our DB's .name
        query = request.query_params.get('universityName') or university.name

        api_key = getattr(settings, 'NEWS_API_KEY', None)
        if not api_key:
            return Response({"detail": "NEWS_API_KEY not configured."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # We'll do "Stanford University" as the final query
        # (some people like to add "University" if it's missing, but it's optional)
        if not query.lower().endswith("university"):
            query += " University"

        news_data = get_news_articles(api_key, query=query, page=page)
        if not news_data:
            return Response({"detail": "No news found."}, status=status.HTTP_200_OK)

        return Response(news_data, status=status.HTTP_200_OK)