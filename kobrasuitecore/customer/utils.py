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