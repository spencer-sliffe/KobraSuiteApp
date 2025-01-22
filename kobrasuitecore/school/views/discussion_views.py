import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, DjangoModelPermissions
from django.contrib.contenttypes.models import ContentType

from school.models import DiscussionThread, DiscussionPost
from school.serializers.discussion_serializers import DiscussionThreadSerializer, DiscussionPostSerializer
from school.permissions.discussion_permissions import IsThreadMember, IsPostAuthorOrThreadMember
from school.pagination import DiscussionPagination

logger = logging.getLogger(__name__)


class DiscussionThreadViewSet(viewsets.ModelViewSet):
    queryset = DiscussionThread.objects.all().select_related('created_by', 'scope_content_type')
    serializer_class = DiscussionThreadSerializer
    permission_classes = [IsAuthenticated, DjangoModelPermissions, IsThreadMember]
    pagination_class = DiscussionPagination

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
        logger.info(f"DiscussionThread created by {self.request.user.username}")

    @action(detail=False, methods=['get'], url_path='by_scope')
    def by_scope(self, request):
        scope_model = request.query_params.get('scope_model')
        scope_id = request.query_params.get('scope_id')
        if not scope_model or not scope_id:
            return Response({"detail": "Provide scope_model and scope_id."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            content_type = ContentType.objects.get(model=scope_model.lower())
        except ContentType.DoesNotExist:
            return Response({"detail": "Invalid scope_model."}, status=status.HTTP_400_BAD_REQUEST)
        threads = DiscussionThread.objects.filter(
            scope_content_type=content_type,
            scope_object_id=scope_id
        ).select_related('created_by')
        page = self.paginate_queryset(threads)
        if page is not None:
            serializer = self.get_serializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = DiscussionThreadSerializer(threads, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class DiscussionPostViewSet(viewsets.ModelViewSet):
    queryset = DiscussionPost.objects.all().select_related('thread', 'author')
    serializer_class = DiscussionPostSerializer
    permission_classes = [IsAuthenticated, DjangoModelPermissions, IsPostAuthorOrThreadMember]
    pagination_class = DiscussionPagination

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
        logger.info(f"DiscussionPost created by {self.request.user.username}")

    @action(detail=False, methods=['get'], url_path='for_thread')
    def for_thread(self, request):
        thread_id = request.query_params.get('thread_id')
        if not thread_id:
            return Response({"detail": "Provide thread_id."}, status=status.HTTP_400_BAD_REQUEST)
        posts = DiscussionPost.objects.filter(thread_id=thread_id).select_related('author').order_by('created_at')
        page = self.paginate_queryset(posts)
        if page is not None:
            serializer = self.get_serializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = DiscussionPostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)