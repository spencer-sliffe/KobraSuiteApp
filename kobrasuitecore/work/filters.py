"""
------------------Prologue--------------------
File Name: filters.py
Path: kobrasuitecore/work/filters.py

Description:
Defines filter sets for querying workplace member data.
Enables searching of user records based on username using case-insensitive partial matching.

Input:
Query parameters for filtering workplace members.

Output:
Filtered QuerySets of user data that meet the search criteria.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
import django_filters
from customer.models import User


class WorkplaceMemberFilter(django_filters.FilterSet):
    search = django_filters.CharFilter(field_name='username', lookup_expr='icontains')

    class Meta:
        model = User
        fields = ['search']