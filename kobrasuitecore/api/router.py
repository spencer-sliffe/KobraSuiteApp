# api/router.py
from rest_framework_nested import routers

from customer.views.auth_views import AuthViewSet
from customer.views.profile_views import SchoolProfileViewSet, UserProfileViewSet, WorkProfileViewSet
from customer.views.user_views import UserViewSet, RoleViewSet
from homelife.views import HouseholdViewSet, ChoreViewSet, SharedCalendarEventViewSet
from finances.views import BankAccountViewSet, BudgetViewSet, TransactionViewSet
from school.views.university_views import UniversityViewSet
from school.views.course_views import CourseViewSet
from school.views.topic_views import TopicViewSet
from school.views.assignment_views import AssignmentViewSet, SubmissionViewSet
from school.views.discussion_views import DiscussionThreadViewSet, DiscussionPostViewSet
from notifications.views import NotificationViewSet
from ai.views import ChatBotViewSet, VerifyCourseViewSet
from work.views.workplace_views import WorkPlaceViewSet

router = routers.DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'users', UserViewSet, basename='users')
router.register(r'roles', RoleViewSet, basename='roles')
router.register(r'households', HouseholdViewSet, basename='households')
router.register(r'chores', ChoreViewSet, basename='chores')
router.register(r'shared-events', SharedCalendarEventViewSet, basename='sharedcalendar')
router.register(r'bank-accounts', BankAccountViewSet, basename='bankaccounts')
router.register(r'budgets', BudgetViewSet, basename='budgets')
router.register(r'transactions', TransactionViewSet, basename='transactions')
router.register(r'discussion-threads', DiscussionThreadViewSet, basename='discussionthreads')
router.register(r'discussion-posts', DiscussionPostViewSet, basename='discussionposts')
router.register(r'notifications', NotificationViewSet, basename='notifications')
router.register(r'chatbot', ChatBotViewSet, basename='chatbot')

# Nested routers for User -> Profile
user_router = routers.NestedDefaultRouter(router, r'users', lookup='user')
user_router.register(r'school_profile', SchoolProfileViewSet, basename='school_profile')
user_router.register(r'user_profile', UserProfileViewSet, basename='user_profile')
user_router.register(r'work_profile', WorkProfileViewSet, basename='work_profile')

# Nested routers for SchoolProfile -> Universities
school_profile_router = routers.NestedDefaultRouter(user_router, r'school_profile', lookup='school_profile')
school_profile_router.register(r'universities', UniversityViewSet, basename='university')

# Nested routers for Universities -> Courses
university_router = routers.NestedDefaultRouter(school_profile_router, r'universities', lookup='university')
university_router.register(r'courses', CourseViewSet, basename='course')
university_router.register(r'verify_course_existence', VerifyCourseViewSet, basename='verify_course_existence')

# Nested routers for Courses -> Assignments and Topics
course_router = routers.NestedDefaultRouter(university_router, r'courses', lookup='course')
course_router.register(r'assignments', AssignmentViewSet, basename='assignment')
course_router.register(r'topics', TopicViewSet, basename='topic')

# Nested routers for Assignments -> Submissions
assignment_router = routers.NestedDefaultRouter(course_router, r'assignments', lookup='assignment')
assignment_router.register(r'submissions', SubmissionViewSet, basename='submission')

# Nested routers for Topics -> StudyDocuments
topic_router = routers.NestedDefaultRouter(course_router, r'topics', lookup='topic')

# Nested routers for WorkProfile -> WorkPlace...
work_profile_router = routers.NestedDefaultRouter(user_router, r'work_profile', lookup='work_profile')
work_profile_router.register(r'work_place', WorkPlaceViewSet, basename='work_place')

work_place_router = routers.NestedDefaultRouter(work_profile_router, r'work_place', lookup='work_place')

urlpatterns = [
    *router.urls,
    *user_router.urls,
    *school_profile_router.urls,
    *university_router.urls,
    *course_router.urls,
    *assignment_router.urls,
    *topic_router.urls,
]