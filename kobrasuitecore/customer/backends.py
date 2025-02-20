"""
------------------Prologue--------------------
File Name: backends.py
Path: kobrasuitecore/customer/backends.py

Description:
Defines a custom authentication backend that merges role-based permissions with standard
Django permission checks. Permits layered authorization for users based on assigned roles.

Input:
User credentials and role associations.

Output:
Permission decisions granting or denying access to protected resources.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# customer/backends.py

from django.contrib.auth.backends import ModelBackend
from django.contrib.auth.models import Permission


class RolePermissionBackend(ModelBackend):
    def get_role_permissions(self, user_obj):
        if not hasattr(user_obj, 'roles'):
            return set()

        role_permissions_qs = Permission.objects.filter(
            roles__users=user_obj
        ).distinct()

        return {
            f"{perm.content_type.app_label}.{perm.codename}"
            for perm in role_permissions_qs
        }

    def get_all_permissions(self, user_obj, obj=None):
        if not user_obj.is_active or user_obj.is_anonymous:
            return set()
        builtin_perms = super().get_all_permissions(user_obj, obj=obj)
        role_perms = self.get_role_permissions(user_obj)
        return builtin_perms.union(role_perms)

    def has_perm(self, user_obj, perm, obj=None):
        if user_obj.is_superuser:
            return True
        return perm in self.get_all_permissions(user_obj, obj=obj)