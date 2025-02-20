"""
------------------Prologue--------------------
File Name: discussion_serializers.py
Path: kobrasuitecore/school/serializers/discussion_serializers.py

Description:
Provides serializer classes for managing discussion threads and posts.
DiscussionThreadSerializer formats thread data including dynamic scope model information.
DiscussionPostSerializer validates and structures individual discussion post data ensuring non-empty content.

Input:
Discussion thread and post data from API requests.

Output:
Validated JSON representations for discussion threads and posts.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import serializers
from django.contrib.contenttypes.models import ContentType
from school.models import DiscussionThread, DiscussionPost


class DiscussionThreadSerializer(serializers.ModelSerializer):
    scope_model = serializers.SerializerMethodField()
    scope_id = serializers.IntegerField(source='scope_object_id')

    class Meta:
        model = DiscussionThread
        fields = [
            'id', 'scope_model', 'scope_id', 'title', 'created_by', 'created_at',
        ]
        read_only_fields = ['created_by', 'created_at']

    def get_scope_model(self, obj):
        return obj.scope_content_type.model

    def validate(self, attrs):
        request = self.context.get('request')
        if request and request.method.lower() == 'post':
            scope_id = attrs.get('scope_object_id')
            scope_model = self.initial_data.get('scope_model')
            if not scope_id or not scope_model:
                raise serializers.ValidationError("Both 'scope_model' and 'scope_id' are required.")
            try:
                content_type = ContentType.objects.get(model=scope_model.lower())
            except ContentType.DoesNotExist:
                raise serializers.ValidationError("Invalid scope_model provided.")
            attrs['scope_content_type'] = content_type
        return attrs

    def create(self, validated_data):
        return DiscussionThread.objects.create(**validated_data)


class DiscussionPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = DiscussionPost
        fields = [
            'id', 'thread', 'author', 'content', 'created_at',
        ]
        read_only_fields = ['author', 'created_at']

    def validate_content(self, value):
        if not value.strip():
            raise serializers.ValidationError("Content cannot be empty.")
        return value

    def create(self, validated_data):
        return DiscussionPost.objects.create(**validated_data)