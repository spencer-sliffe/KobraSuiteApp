from rest_framework import permissions
from school.models import University, Course, Assignment


class IsThreadMember(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        user = request.user
        if not hasattr(user, 'school_profile'):
            return False

        school_profile = user.school_profile

        if isinstance(obj.scope, University):
            user_uni = getattr(school_profile, 'university', None)
            if user_uni and user_uni.id == obj.scope.id:
                return True

        if isinstance(obj.scope, Course):
            user_uni = getattr(school_profile, 'university', None)
            user_courses = school_profile.courses.all() if hasattr(school_profile, 'courses') else []
            if user_uni and user_uni.id == obj.scope.university.id and obj.scope in user_courses:
                return True

        if isinstance(obj.scope, Assignment):
            assignment_course = obj.scope.course
            user_uni = getattr(school_profile, 'university', None)
            user_courses = school_profile.courses.all() if hasattr(school_profile, 'courses') else []
            if user_uni and user_uni.id == assignment_course.university.id and assignment_course in user_courses:
                return True

        return False


class IsPostAuthorOrThreadMember(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user == obj.author:
            return True
        thread = obj.thread
        thread_member_permission = IsThreadMember()
        return thread_member_permission.has_object_permission(request, view, thread)