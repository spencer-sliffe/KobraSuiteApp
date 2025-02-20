"""
------------------Prologue--------------------
File Name: pagination.py
Path: kobrasuitecore/school/pagination.py

Description:
Defines a pagination class specifically for discussion-related API endpoints.
Sets default page sizes and limits while allowing client-driven adjustments via query parameters.

Input:
Pagination parameters provided in client API requests.

Output:
Paginated response objects for discussion data.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework.pagination import PageNumberPagination


class DiscussionPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100