from rest_framework_nested import routers

from customer.views.auth_views import AuthViewSet
from hq.views.module_task_views import ModuleTaskViewSet
from hq.views.work_profile_views import WorkProfileViewSet
from hq.views.homelife_profile_views import HomeLifeProfileViewSet
from hq.views.finance_profile_views import FinanceProfileViewSet
from hq.views.school_profile_views import SchoolProfileViewSet
from customer.views.user_views import UserViewSet
from finances.views.stock_views import (
    StockPortfolioViewSet,
    PortfolioStockViewSet,
    WatchlistStockViewSet,
)
from finances.views.banking_views import (
    BankAccountViewSet,
    BudgetViewSet,
    BudgetCategoryViewSet,
    TransactionViewSet
)
from finances.views.misc_invest_views import MiscInvestViewSet
from hq.views.user_profile_views import UserProfileViewSet
from school.views.university_views import UniversityViewSet
from school.views.course_views import CourseViewSet
from school.views.topic_views import TopicViewSet
from school.views.assignment_views import AssignmentViewSet, SubmissionViewSet
from school.views.discussion_views import DiscussionThreadViewSet, DiscussionPostViewSet
from ai.views.chatgpt_views import ChatBotViewSet, VerifyCourseViewSet
from work.views.workplace_views import WorkPlaceViewSet
from ai.views.image_generation_views import ImageGenerationViewSet

router = routers.DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'users', UserViewSet, basename='users')
router.register(r'discussion-threads', DiscussionThreadViewSet, basename='discussionthreads')
router.register(r'discussion-posts', DiscussionPostViewSet, basename='discussionposts')
router.register(r'chatbot', ChatBotViewSet, basename='chatbot')
router.register(r'image-generation', ImageGenerationViewSet, basename='image_generation')

user_router = routers.NestedDefaultRouter(router, r'users', lookup='user')
user_router.register(r'school_profile', SchoolProfileViewSet, basename='school_profile')
user_router.register(r'user_profile', UserProfileViewSet, basename='user_profile')
user_router.register(r'work_profile', WorkProfileViewSet, basename='work_profile')
user_router.register(r'finance_profile', FinanceProfileViewSet, basename='finance_profile')
user_router.register(r'homelife_profile', HomeLifeProfileViewSet, basename='homelife_profile')

hq_router = routers.NestedDefaultRouter(user_router, r'hq', lookup='hq')
hq_router.register(r'tasks', ModuleTaskViewSet, 'task')

homelife_profile_router = routers.NestedDefaultRouter(user_router, r'homelife_profile', lookup='homelife_profile')

school_profile_router = routers.NestedDefaultRouter(user_router, r'school_profile', lookup='school_profile')
school_profile_router.register(r'universities', UniversityViewSet, basename='university')

university_router = routers.NestedDefaultRouter(school_profile_router, r'universities', lookup='university')
university_router.register(r'courses', CourseViewSet, basename='course')
university_router.register(r'verify_course_existence', VerifyCourseViewSet, basename='verify_course_existence')

course_router = routers.NestedDefaultRouter(university_router, r'courses', lookup='course')
course_router.register(r'assignments', AssignmentViewSet, basename='assignment')
course_router.register(r'topics', TopicViewSet, basename='topic')

assignment_router = routers.NestedDefaultRouter(course_router, r'assignments', lookup='assignment')
assignment_router.register(r'submissions', SubmissionViewSet, basename='submission')

topic_router = routers.NestedDefaultRouter(course_router, r'topics', lookup='topic')

work_profile_router = routers.NestedDefaultRouter(user_router, r'work_profile', lookup='work_profile')
work_profile_router.register(r'work_place', WorkPlaceViewSet, basename='work_place')
work_place_router = routers.NestedDefaultRouter(work_profile_router, r'work_place', lookup='work_place')

finance_profile_router = routers.NestedDefaultRouter(user_router, r'finance_profile', lookup='finance_profile')
finance_profile_router.register(r'stock_portfolio', StockPortfolioViewSet, basename='stock_portfolio')
finance_profile_router.register(r'bank_accounts', BankAccountViewSet, basename='bank_account')
finance_profile_router.register(r'budgets', BudgetViewSet, basename='budget')
finance_profile_router.register(r'budget_categories', BudgetCategoryViewSet, basename='budget_category')
finance_profile_router.register(r'transactions', TransactionViewSet, basename='transaction')

stock_portfolio_router = routers.NestedDefaultRouter(finance_profile_router, r'stock_portfolio', lookup='stock_portfolio')
stock_portfolio_router.register(r'portfolio_stocks', PortfolioStockViewSet, basename='portfolio_stock')
stock_portfolio_router.register(r'watchlist_stocks', WatchlistStockViewSet, basename='watchlist_stock')

router.register(r'misc_invest', MiscInvestViewSet, basename='misc_invests')


urlpatterns = [
    *router.urls,
    *user_router.urls,
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
]