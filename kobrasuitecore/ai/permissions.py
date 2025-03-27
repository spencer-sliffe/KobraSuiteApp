"""
------------------Prologue--------------------
File Name: permissions.py
Path: kobrasuitecore/ai/permissions.py

Description:
Implements custom permission classes to ensure only authenticated and active users can interact
with the chatbot and course verification features.

Input:
HTTP requests validated against user authentication status.

Output:
Access granted or denied based on permissions logic.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# ai/permissions.py

from rest_framework import permissions

class IsAuthenticatedAndActive(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.is_active # returns user, authentication and is active from db