# File: ai/views/image_generation_viewset.py
import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from ai.serializers.image_generation_serializers import ImageGenerationRequestSerializer, AbstractBannerResponseSerializer
from ai.services.image_generation_service import generate_banner_colors

logger = logging.getLogger(__name__)

class ImageGenerationViewSet(viewsets.ViewSet):
    """
    ViewSet for generating abstract banner color palettes using ChatGPT.
    """
    parser_classes = [JSONParser]

    @action(detail=False, methods=['post'], url_path='generate')
    def generate(self, request):
        serializer = ImageGenerationRequestSerializer(data=request.data)
        if serializer.is_valid():
            prompt = serializer.validated_data.get('prompt')
            try:
                colors = generate_banner_colors(prompt)
                response_serializer = AbstractBannerResponseSerializer({'color_palette': colors})
                return Response(response_serializer.data, status=status.HTTP_200_OK)
            except Exception as e:
                logger.error("Banner color generation failed: %s", str(e))
                return Response({"detail": "Banner color generation failed."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)