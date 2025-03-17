"""
------------------Prologue--------------------
File Name: workplace_serializers.py
Path: kobrasuitecore/work/serializers/workplace_serializers.py

Description:
Defines serializer classes for work-related data, specifically for the WorkPlace model.
Includes fields such as name, field, website, invite_code, owner, identity_image, created_at, and a computed member_count.
Serializes associated owner information using the UserSerializer.

Input:
WorkPlace model instance data.

Output:
Validated and structured JSON representations of workplace data.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import serializers
from work.models import WorkPlace
from customer.serializers.user_serializers import UserSerializer

# creaets Work PLace Serializer
class WorkPlaceSerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)
    member_count = serializers.ReadOnlyField()
# serializer Structure
    class Meta:
        model = WorkPlace
        fields = ['id', 'name', 'field', 'website', 'invite_code', 'owner', 'identity_image', 'created_at', 'member_count']