import django_filters
from customer.models import User


class WorkplaceMemberFilter(django_filters.FilterSet):
    search = django_filters.CharFilter(field_name='username', lookup_expr='icontains')

    class Meta:
        model = User
        fields = ['search']