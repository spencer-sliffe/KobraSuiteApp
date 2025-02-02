# File: ai/views/image_generation_viewset.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import JSONParser
from ai.serializers.image_generation_serializers import ImageGenerationRequestSerializer, ImageGenerationResponseSerializer
from ai.services.image_generation_service import generate_image
import logging

logger = logging.getLogger(__name__)

class ImageGenerationViewSet(viewsets.ViewSet):
    """
    ViewSet for generating images using the OpenAI DALL-E 3 service.
    """
    parser_classes = [JSONParser]

    @action(detail=False, methods=['post'], url_path='generate')
    def generate(self, request):
        serializer = ImageGenerationRequestSerializer(data=request.data)
        if serializer.is_valid():
            prompt = serializer.validated_data.get('prompt')
            try:
                image_url = generate_image(prompt)
                response_serializer = ImageGenerationResponseSerializer({'image_url': image_url})
                return Response(response_serializer.data, status=status.HTTP_200_OK)
            except Exception as e:
                logger.error("Image generation failed: %s", str(e))
                return Response({"detail": "Image generation failed."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)