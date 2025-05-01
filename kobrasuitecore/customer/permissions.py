from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj == request.user


# class IsOwnerOrAdmin(permissions.BasePermission):
#     def has_object_permission(self, request, view, obj):
#         return request.user.is_superuser or request.user.is_staff or obj == request.user or obj.profile.user == request.user
#
#
# class IsObjOwner(permissions.BasePermission):
#     def has_object_permission(self, request, view, obj):
#         return request.user.is_superuser or request.user.is_staff or obj.profile.user == request.user
#

class IsAdminOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated
        return request.user and request.user.is_staff