from rest_framework_nested import routers

from customer.views.auth_views import AuthViewSet
from hq.views.homelife_profile_views import HomeLifeProfileViewSet
from hq.views.profile_views import (
    SchoolProfileViewSet,
    WorkProfileViewSet,
    FinanceProfileViewSet
)
from customer.views.user_views import UserViewSet, RoleViewSet
from finances.views.crypto_views import (
    CryptoPortfolioViewSet,
    PortfolioCryptoViewSet,
    WatchlistCryptoViewSet,
    FavoriteCryptoViewSet
)
from finances.views.stock_views import (
    StockPortfolioViewSet,
    PortfolioStockViewSet,
    WatchlistStockViewSet,
    FavoriteStockViewSet
)
from finances.views.misc_invest_views import MiscInvestViewSet
from homelife.views import HouseholdViewSet, ChoreViewSet, SharedCalendarEventViewSet
from hq.views.user_profile_views import UserProfileViewSet
from school.views.university_views import UniversityViewSet
from school.views.course_views import CourseViewSet
from school.views.topic_views import TopicViewSet
from school.views.assignment_views import AssignmentViewSet, SubmissionViewSet
from school.views.discussion_views import DiscussionThreadViewSet, DiscussionPostViewSet
from notifications.views import NotificationViewSet
from ai.views import ChatBotViewSet, VerifyCourseViewSet
from work.views.workplace_views import WorkPlaceViewSet

# Main router
router = routers.DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'users', UserViewSet, basename='users')
router.register(r'roles', RoleViewSet, basename='roles')
router.register(r'households', HouseholdViewSet, basename='households')
router.register(r'chores', ChoreViewSet, basename='chores')
router.register(r'shared-events', SharedCalendarEventViewSet, basename='sharedcalendar')
router.register(r'discussion-threads', DiscussionThreadViewSet, basename='discussionthreads')
router.register(r'discussion-posts', DiscussionPostViewSet, basename='discussionposts')
router.register(r'notifications', NotificationViewSet, basename='notifications')
router.register(r'chatbot', ChatBotViewSet, basename='chatbot')

# User-level nested router
user_router = routers.NestedDefaultRouter(router, r'users', lookup='user')
user_router.register(r'school_profile', SchoolProfileViewSet, basename='school_profile')
user_router.register(r'user_profile', UserProfileViewSet, basename='user_profile')
user_router.register(r'work_profile', WorkProfileViewSet, basename='work_profile')
user_router.register(r'finance_profile', FinanceProfileViewSet, basename='finance_profile')

# SchoolProfile -> University
school_profile_router = routers.NestedDefaultRouter(user_router, r'school_profile', lookup='school_profile')
school_profile_router.register(r'universities', UniversityViewSet, basename='university')

# University -> Courses
university_router = routers.NestedDefaultRouter(school_profile_router, r'universities', lookup='university')
university_router.register(r'courses', CourseViewSet, basename='course')
university_router.register(r'verify_course_existence', VerifyCourseViewSet, basename='verify_course_existence')

# Course -> Assignments, Topics
course_router = routers.NestedDefaultRouter(university_router, r'courses', lookup='course')
course_router.register(r'assignments', AssignmentViewSet, basename='assignment')
course_router.register(r'topics', TopicViewSet, basename='topic')

# Assignment -> Submissions
assignment_router = routers.NestedDefaultRouter(course_router, r'assignments', lookup='assignment')
assignment_router.register(r'submissions', SubmissionViewSet, basename='submission')

# (Optional) topic_router for nested documents, if needed:
topic_router = routers.NestedDefaultRouter(course_router, r'topics', lookup='topic')

# WorkProfile -> WorkPlace
work_profile_router = routers.NestedDefaultRouter(user_router, r'work_profile', lookup='work_profile')
work_profile_router.register(r'work_place', WorkPlaceViewSet, basename='work_place')
work_place_router = routers.NestedDefaultRouter(work_profile_router, r'work_place', lookup='work_place')

# FinanceProfile -> StockPortfolio, CryptoPortfolio
finance_profile_router = routers.NestedDefaultRouter(user_router, r'finance_profile', lookup='finance_profile')
finance_profile_router.register(r'stock_portfolio', StockPortfolioViewSet, basename='stock_portfolio')
finance_profile_router.register(r'crypto_portfolio', CryptoPortfolioViewSet, basename='crypto_portfolio')

# StockPortfolio -> Stocks (favorites, watchlists)
stock_portfolio_router = routers.NestedDefaultRouter(finance_profile_router, r'stock_portfolio', lookup='stock_portfolio')
stock_portfolio_router.register(r'portfolio_stocks', PortfolioStockViewSet, basename='portfolio_stock')
stock_portfolio_router.register(r'watchlist_stocks', WatchlistStockViewSet, basename='watchlist_stock')
stock_portfolio_router.register(r'favorite_stocks', FavoriteStockViewSet, basename='favorite_stock')

# CryptoPortfolio -> Cryptos (favorites, watchlists)
crypto_portfolio_router = routers.NestedDefaultRouter(finance_profile_router, r'crypto_portfolio', lookup='crypto_portfolio')
crypto_portfolio_router.register(r'portfolio_cryptos', PortfolioCryptoViewSet, basename='portfolio_crypto')
crypto_portfolio_router.register(r'watchlist_cryptos', WatchlistCryptoViewSet, basename='watchlist_crypto')
crypto_portfolio_router.register(r'favorite_cryptos', FavoriteCryptoViewSet, basename='favorite_crypto')

# Homelife
user_router.register(r'homelife_profile', HomeLifeProfileViewSet, basename='homelife_profile')
homelife_profile_router = routers.NestedDefaultRouter(user_router, r'homelife_profile', lookup='homelife_profile')
homelife_profile_router.register(r'household', HouseholdViewSet, basename='household')

# Top-level route for misc investing features (stock/crypto data, charts, news, predictions)
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
    *crypto_portfolio_router.urls,
    homelife_profile_router.urls,
]