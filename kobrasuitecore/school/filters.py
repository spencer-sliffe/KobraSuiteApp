# school/filters.py

import django_filters
from .models import University, Course, Assignment, Topic, StudyDocument, Submission


class UniversityFilter(django_filters.FilterSet):
    name = django_filters.CharFilter(field_name='name', lookup_expr='icontains')
    country = django_filters.CharFilter(field_name='country', lookup_expr='icontains')

    class Meta:
        model = University
        fields = ['name', 'country']


class CourseFilter(django_filters.FilterSet):
    course_code = django_filters.CharFilter(field_name='course_code', lookup_expr='icontains')
    title = django_filters.CharFilter(field_name='title', lookup_expr='icontains')
    professor_last_name = django_filters.CharFilter(field_name='professor_last_name', lookup_expr='icontains')
    department = django_filters.CharFilter(field_name='department', lookup_expr='icontains')

    class Meta:
        model = Course
        fields = ['course_code', 'title', 'professor_last_name', 'department']


class AssignmentFilter(django_filters.FilterSet):
    title = django_filters.CharFilter(lookup_expr='icontains')
    min_due_date = django_filters.DateTimeFilter(field_name='due_date', lookup_expr='gte')
    max_due_date = django_filters.DateTimeFilter(field_name='due_date', lookup_expr='lte')

    class Meta:
        model = Assignment
        fields = ['title', 'course', 'min_due_date', 'max_due_date']


class TopicFilter(django_filters.FilterSet):
    name = django_filters.CharFilter(field_name='name', lookup_expr='icontains')
    course = django_filters.NumberFilter(field_name='course_id')

    class Meta:
        model = Topic
        fields = ['name', 'course']


class StudyDocumentFilter(django_filters.FilterSet):
    title = django_filters.CharFilter(field_name='title', lookup_expr='icontains')
    author = django_filters.NumberFilter(field_name='author_id')

    class Meta:
        model = StudyDocument
        fields = ['title', 'author']


class SubmissionFilter(django_filters.FilterSet):
    assignment = django_filters.NumberFilter(field_name='assignment_id')
    student = django_filters.NumberFilter(field_name='student_id')
    submitted_before = django_filters.DateTimeFilter(field_name='submitted_at', lookup_expr='lte')
    submitted_after = django_filters.DateTimeFilter(field_name='submitted_at', lookup_expr='gte')

    class Meta:
        model = Submission
        fields = ['assignment', 'student', 'submitted_before', 'submitted_after']