# ai/serializers/image_generation_serializers.py
from rest_framework import serializers


class ImageGenerationRequestSerializer(serializers.Serializer):
    prompt = serializers.CharField(max_length=1000)


class ImageGenerationResponseSerializer(serializers.Serializer):
    image_url = serializers.CharField()