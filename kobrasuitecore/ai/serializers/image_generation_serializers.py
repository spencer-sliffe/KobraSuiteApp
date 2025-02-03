# File: ai/serializers/image_generation_serializers.py
from rest_framework import serializers


class ImageGenerationRequestSerializer(serializers.Serializer):
    prompt = serializers.CharField(max_length=1000)


class AbstractBannerResponseSerializer(serializers.Serializer):
    color_palette = serializers.ListField(child=serializers.CharField())