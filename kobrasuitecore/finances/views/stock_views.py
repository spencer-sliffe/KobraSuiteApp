"""
------------------Prologue--------------------
File Name: stock_views.py
Path: kobrasuitecore/finances/views/stock_views.py

Description:
Implements endpoints for managing stock portfolios: adding or removing tickers,
fetching positions, and performing portfolio-level analytics. Relies on utility
and service layers to handle data integrity and external lookups.

Input:
User-provided portfolio identifiers, ticker symbols, share counts, and optional dates.

Output:
Structured JSON containing updated portfolio data, success/error messages,
or portfolio analysis results.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from django.utils.dateparse import parse_datetime
from hq.models import FinanceProfile
from finances.models import StockPortfolio, PortfolioStock, WatchlistStock
from finances.serializers.stock_serializers import (
    StockPortfolioSerializer,
    PortfolioStockSerializer,
    WatchlistStockSerializer
)
from finances.services.stock_services import (
    get_or_create_stock_portfolio,
    add_stock_to_portfolio,
    remove_stock_from_portfolio,
    get_portfolio_stocks,
    portfolio_analysis
)
from finances.utils.stock_utils import check_stock_validity


class StockPortfolioViewSet(viewsets.ModelViewSet):
    """
    Provides CRUD for StockPortfolio objects, nested under FinanceProfile.
    Can retrieve, create (or auto-create) a portfolio, add or remove stocks,
    and perform analysis.
    """
    http_method_names = ['get', 'post', 'delete', 'patch']
    queryset = StockPortfolio.objects.all()
    serializer_class = StockPortfolioSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Enforces nested lookup:
        /users/<user_pk>/user_profile/<user_profile_pk>/finance_profile/<finance_profile_pk>/stock_portfolio/
        """
        user_pk = self.kwargs.get('user_pk')
        user_profile_pk = self.kwargs.get('user_profile_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(
            finance_profile_id=finance_profile_pk,
            finance_profile__profile_id=user_profile_pk,
            finance_profile__profile__user_id=user_pk
        )

    def create(self, request, user_pk=None, user_profile_pk=None, finance_profile_pk=None):
        """
        Creates or retrieves a StockPortfolio for the given FinanceProfile.
        """
        finance_profile = get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=user_profile_pk,
            profile__user__id=user_pk
        )
        portfolio = get_or_create_stock_portfolio(finance_profile)
        serializer = self.get_serializer(portfolio)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['get'])
    def stocks(self, request, pk=None, user_pk=None, user_profile_pk=None, finance_profile_pk=None):
        """
        Retrieves all stocks within the specified portfolio.
        """
        finance_profile = get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=user_profile_pk,
            profile__user__id=user_pk
        )
        data = get_portfolio_stocks(finance_profile, portfolio_id=pk)
        return Response(data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def add_stock(self, request, pk=None, user_pk=None, user_profile_pk=None, finance_profile_pk=None):
        """
        Adds a given ticker to the specified portfolio.
        """
        finance_profile = get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=user_profile_pk,
            profile__user__id=user_pk
        )
        ticker = request.data.get('ticker')
        num_shares = request.data.get('num_shares')
        if not ticker or num_shares is None:
            return Response(
                {'error': 'ticker and num_shares are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not check_stock_validity(ticker):
            return Response(
                {'error': 'Invalid stock ticker'},
                status=status.HTTP_400_BAD_REQUEST
            )
        date_str = request.data.get('purchase_date')
        dt = parse_datetime(date_str) if date_str else None
        success = add_stock_to_portfolio(finance_profile, pk, ticker, float(num_shares), dt)
        if success:
            return Response({'message': f'{ticker} added.'}, status=status.HTTP_200_OK)
        return Response(
            {'error': 'Failed to add stock'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    @action(
        detail=True,
        methods=['delete'],
        url_path='remove_stock/(?P<ticker>[^/.]+)'
    )
    def remove_stock(self, request, ticker=None, pk=None, user_pk=None, user_profile_pk=None, finance_profile_pk=None):
        """
        Removes a specified ticker from the portfolio.
        """
        finance_profile = get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=user_profile_pk,
            profile__user__id=user_pk
        )
        success = remove_stock_from_portfolio(finance_profile, pk, ticker)
        if success:
            return Response({'message': f'{ticker} removed.'}, status=status.HTTP_200_OK)
        return Response(
            {'error': 'Failed to remove stock'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    @action(detail=True, methods=['get'])
    def analysis(self, request, pk=None, user_pk=None, user_profile_pk=None, finance_profile_pk=None):
        """
        Performs a portfolio analysis for the specified portfolio
        (e.g., weighting, total value).
        """
        finance_profile = get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=user_profile_pk,
            profile__user__id=user_pk
        )
        stocks_data = get_portfolio_stocks(finance_profile, pk)
        if not stocks_data:
            return Response(
                {'error': 'No stocks in this portfolio.'},
                status=status.HTTP_404_NOT_FOUND
            )
        structure = {s['ticker']: s['number_of_shares'] for s in stocks_data}
        result = portfolio_analysis(structure)
        if not result:
            return Response(
                {'error': 'Error analyzing portfolio'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        return Response(result, status=status.HTTP_200_OK)


class PortfolioStockViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only view for PortfolioStock objects. Typically nested
    under a specific StockPortfolio in the router.
    """
    queryset = PortfolioStock.objects.all()
    serializer_class = PortfolioStockSerializer
    permission_classes = [IsAuthenticated]


class WatchlistStockViewSet(viewsets.ModelViewSet):
    """
    CRUD for WatchlistStock objects. Typically nested under a
    specific StockPortfolio in the router.
    """
    queryset = WatchlistStock.objects.all()
    serializer_class = WatchlistStockSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Filters watchlist stocks by the associated stock_portfolio_pk
        from the nested route.
        """
        stock_portfolio_pk = self.kwargs.get('stock_portfolio_pk')
        return self.queryset.filter(portfolio__pk=stock_portfolio_pk)