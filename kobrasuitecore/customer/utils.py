"""
------------------Prologue--------------------
File Name: utils.py
Path: kobrasuitecore/customer/utils.py

Description:
Provides utility functions to assign or remove roles from users, managing membership in
the Role model as part of user authorization logic.

Input:
User instances and role names.

Output:
Role associations updated within the database for specified users.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
def assign_role_to_user(user, role_name):
    from .models import Role
    try:
        role = Role.objects.get(name=role_name)
        user.roles.add(role)
    except Role.DoesNotExist:
        raise ValueError(f"Role '{role_name}' does not exist")


def remove_role_from_user(user, role_name):
    from .models import Role
    try:
        role = Role.objects.get(name=role_name)
        user.roles.remove(role)
    except Role.DoesNotExist:
        pass