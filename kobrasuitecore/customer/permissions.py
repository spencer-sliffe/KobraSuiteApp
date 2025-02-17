"""
------------------Prologue--------------------
File Name: permissions.py
Path: kobrasuitecore/customer/permissions.py

Description:
Declares permission classes controlling object-level access. Allows owners or administrators
to manage resources, ensuring security for sensitive data.

Input:
HTTP requests evaluated against user roles, ownership, or admin status.

Output:
Permission grants or denials for resource access.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj == request.user


class IsOwnerOrAdmin(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return request.user.is_superuser or request.user.is_staff or obj.user == request.user or obj == request.user


class IsAdminOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated
        return request.user and request.user.is_staff