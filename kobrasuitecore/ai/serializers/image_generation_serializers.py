"""
------------------Prologue--------------------
File Name: image_generation_serializers.py
Path: kobrasuitecore/ai/serializers/image_generation_serializers.py

Description:
Offers serializer classes to handle image generation inputs, such as prompts for color palette requests,
and formats the resulting color palette output.

Input:
User-provided prompts for generating a color scheme.

Output:
Validated JSON structures containing color code arrays.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# File: ai/serializers/image_generation_serializers.py
from rest_framework import serializers


class ImageGenerationRequestSerializer(serializers.Serializer):
    prompt = serializers.CharField(max_length=1000)


class AbstractBannerResponseSerializer(serializers.Serializer):
    color_palette = serializers.ListField(child=serializers.CharField())