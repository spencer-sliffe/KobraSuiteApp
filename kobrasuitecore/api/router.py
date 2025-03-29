from rest_framework_nested import routers

from customer.views.auth_views import AuthViewSet
from customer.views.user_views import UserViewSet
from hq.views.task_category_progress_views import TaskCategoryProgressViewSet
from hq.views.school_profile_views import SchoolProfileViewSet
from hq.views.user_profile_views import UserProfileViewSet
from hq.views.work_profile_views import WorkProfileViewSet
from hq.views.finance_profile_views import FinanceProfileViewSet
from hq.views.homelife_profile_views import HomeLifeProfileViewSet
from ai.views.chatgpt_views import ChatBotViewSet, VerifyCourseViewSet
from ai.views.image_generation_views import ImageGenerationViewSet
from school.views.university_views import UniversityViewSet
from school.views.course_views import CourseViewSet
from school.views.topic_views import TopicViewSet
from school.views.assignment_views import AssignmentViewSet, SubmissionViewSet
from school.views.discussion_views import DiscussionThreadViewSet, DiscussionPostViewSet
from work.views.workplace_views import WorkPlaceViewSet
from finances.views.stock_views import StockPortfolioViewSet, PortfolioStockViewSet, WatchlistStockViewSet
from finances.views.banking_views import BankAccountViewSet, BudgetViewSet, BudgetCategoryViewSet, TransactionViewSet
from finances.views.misc_invest_views import MiscInvestViewSet

router = routers.DefaultRouter()
router.register('auth', AuthViewSet, basename='auth')
router.register('users', UserViewSet, basename='users')
router.register('discussion-threads', DiscussionThreadViewSet, basename='discussionthreads')
router.register('discussion-posts', DiscussionPostViewSet, basename='discussionposts')
router.register('chatbot', ChatBotViewSet, basename='chatbot')
router.register('image-generation', ImageGenerationViewSet, basename='image_generation')

# USER
user_router = routers.NestedDefaultRouter(router, 'users', lookup='user')
user_router.register('profile', UserProfileViewSet, basename='profile')

# PROFILE
profile_router = routers.NestedDefaultRouter(user_router, 'profile', lookup='profile')
profile_router.register('school_profile', SchoolProfileViewSet, basename='school_profile')
profile_router.register('work_profile', WorkProfileViewSet, basename='work_profile')
profile_router.register('finance_profile', FinanceProfileViewSet, basename='finance_profile')
profile_router.register('homelife_profile', HomeLifeProfileViewSet, basename='homelife_profile')
profile_router.register('task', TaskCategoryProgressViewSet, basename='task_category_progress')


# SCHOOL
school_profile_router = routers.NestedDefaultRouter(profile_router, 'school_profile', lookup='school_profile')
school_profile_router.register('universities', UniversityViewSet, basename='university')
university_router = routers.NestedDefaultRouter(school_profile_router, 'universities', lookup='university')
university_router.register('courses', CourseViewSet, basename='course')
university_router.register('verify_course_existence', VerifyCourseViewSet, basename='verify_course_existence')
course_router = routers.NestedDefaultRouter(university_router, 'courses', lookup='course')
course_router.register('assignments', AssignmentViewSet, basename='assignment')
course_router.register('topics', TopicViewSet, basename='topic')
assignment_router = routers.NestedDefaultRouter(course_router, 'assignments', lookup='assignment')
assignment_router.register('submissions', SubmissionViewSet, basename='submission')
topic_router = routers.NestedDefaultRouter(course_router, 'topics', lookup='topic')


# WORK
work_profile_router = routers.NestedDefaultRouter(profile_router, 'work_profile', lookup='work_profile')
work_profile_router.register('work_places', WorkPlaceViewSet, basename='work_place')
work_place_router = routers.NestedDefaultRouter(work_profile_router, 'work_places', lookup='work_place')


# FINANCE
finance_profile_router = routers.NestedDefaultRouter(profile_router, 'finance_profile', lookup='finance_profile')
finance_profile_router.register('stock_portfolio', StockPortfolioViewSet, basename='stock_portfolio')
finance_profile_router.register('bank_accounts', BankAccountViewSet, basename='bank_account')
finance_profile_router.register('budgets', BudgetViewSet, basename='budget')
finance_profile_router.register('transactions', TransactionViewSet, basename='transaction')
finance_profile_router.register('misc_invest', MiscInvestViewSet, basename='misc_invests')
stock_portfolio_router = routers.NestedDefaultRouter(finance_profile_router, 'stock_portfolio', lookup='stock_portfolio')
stock_portfolio_router.register('portfolio_stocks', PortfolioStockViewSet, basename='portfolio_stock')
stock_portfolio_router.register('watchlist_stocks', WatchlistStockViewSet, basename='watchlist_stock')
budget_router = routers.NestedDefaultRouter(finance_profile_router, 'budgets', lookup='budget')
budget_router.register('categories', BudgetCategoryViewSet, basename='budget_category')


# HOMELIFE
homelife_profile_router = routers.NestedDefaultRouter(profile_router, 'homelife_profile', lookup='homelife_profile')


# URL PATTERNS
urlpatterns = [
    *router.urls,
    *user_router.urls,
    *profile_router.urls,
    *school_profile_router.urls,
    *university_router.urls,
    *course_router.urls,
    *assignment_router.urls,
    *topic_router.urls,
    *work_profile_router.urls,
    *work_place_router.urls,
    *finance_profile_router.urls,
    *stock_portfolio_router.urls,
    *homelife_profile_router.urls,
    *budget_router.urls,
]