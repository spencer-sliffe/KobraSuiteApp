"""
------------------Prologue--------------------
File Name: stock_views.py
Path: kobrasuitecore/finances/views/stock_views.py

Description:
Implements endpoints for managing stock portfolios: adding or removing
tickers, fetching positions, and performing portfolio‑level analytics.
Relies on utility and service layers to handle data integrity and external
lookups.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
from django.shortcuts import get_object_or_404
from django.utils.dateparse import parse_datetime
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from customer.permissions import IsOwnerOrAdmin
from finances.models import PortfolioStock, StockPortfolio, WatchlistStock
from finances.serializers.stock_serializers import (
    PortfolioStockSerializer,
    StockPortfolioSerializer,
    WatchlistStockSerializer,
)
from finances.services.stock_services import (
    add_stock_to_portfolio,
    build_chat_responses,
    get_or_create_stock_portfolio,
    get_portfolio_stocks,
    portfolio_analysis,
    portfolio_value_series,
    remove_stock_from_portfolio,
)
from finances.utils.stock_utils import check_stock_validity
from hq.models import FinanceProfile


class StockPortfolioViewSet(viewsets.ModelViewSet):
    http_method_names = ["get", "post", "delete", "patch"]
    queryset = StockPortfolio.objects.all()
    serializer_class = StockPortfolioSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    # ------------------------------------------------------------------ #
    # helpers
    # ------------------------------------------------------------------ #
    def _get_finance_profile(self, user_pk, profile_pk, finance_profile_pk):
        return get_object_or_404(
            FinanceProfile,
            pk=finance_profile_pk,
            profile_id=profile_pk,
            profile__user__id=user_pk,
        )

    # ------------------------------------------------------------------ #
    # overrides / custom actions
    # ------------------------------------------------------------------ #
    def get_queryset(self):
        user_pk = self.kwargs.get("user_pk")
        profile_pk = self.kwargs.get("profile_pk")
        finance_profile_pk = self.kwargs.get("finance_profile_pk")
        return self.queryset.filter(
            pk=finance_profile_pk,  # primary‑key match
            finance_profile__profile_id=profile_pk,
            finance_profile__profile__user_id=user_pk,
        )

    def create(self, request, user_pk=None, profile_pk=None, finance_profile_pk=None):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)
        if hasattr(fp, 'stock_portfolio'):
            return Response(
                {'error': 'A stock portfolio already exists for this finance profile.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        portfolio = get_or_create_stock_portfolio(fp)
        return Response(self.get_serializer(portfolio).data, status=status.HTTP_201_CREATED)

    # ---------------------------------------- #
    @action(detail=True, methods=["get"])
    def stocks(self, request, pk=None, user_pk=None, profile_pk=None, finance_profile_pk=None):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)
        data = get_portfolio_stocks(fp)
        return Response(data, status=status.HTTP_200_OK)

    # ---------------------------------------- #
    @action(detail=True, methods=["post"])
    def add_stock(self, request, pk=None, user_pk=None, profile_pk=None, finance_profile_pk=None):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)

        ticker = request.data.get("ticker")
        num_shares = request.data.get("num_shares")
        if not ticker or num_shares is None:
            return Response({"error": "ticker and num_shares are required"}, status=status.HTTP_400_BAD_REQUEST)
        if not check_stock_validity(ticker):
            return Response({"error": "Invalid stock ticker"}, status=status.HTTP_400_BAD_REQUEST)

        dt = parse_datetime(request.data.get("purchase_date") or "")
        if add_stock_to_portfolio(fp, pk, ticker, float(num_shares), dt):
            return Response({"message": f"{ticker} added."}, status=status.HTTP_200_OK)
        return Response({"error": "Failed to add stock"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # ---------------------------------------- #
    @action(detail=True, methods=["delete"], url_path="remove_stock/(?P<ticker>[^/.]+)")
    def remove_stock(
        self,
        request,
        ticker=None,
        pk=None,
        user_pk=None,
        profile_pk=None,
        finance_profile_pk=None,
    ):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)
        if remove_stock_from_portfolio(fp, pk, ticker):
            return Response({"message": f"{ticker} removed."}, status=status.HTTP_200_OK)
        return Response({"error": "Failed to remove stock"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # ---------------------------------------- #
    @action(detail=True, methods=["get"])
    def analysis(self, request, pk=None, user_pk=None, profile_pk=None, finance_profile_pk=None):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)

        rows = get_portfolio_stocks(fp, pk)
        if not rows:
            return Response({"error": "No stocks in this portfolio."}, status=status.HTTP_404_NOT_FOUND)

        structure = {r["ticker"]: r["number_of_shares"] for r in rows}
        metrics = portfolio_analysis(structure)
        if metrics is None:
            return Response({"error": "Error analyzing portfolio"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        chat = build_chat_responses(metrics)
        return Response({"metrics": metrics, "chat_responses": chat}, status=status.HTTP_200_OK)

    # ---------------------------------------- #
    @action(detail=True, methods=["get"])
    def value_series(self, request, pk=None, user_pk=None, profile_pk=None, finance_profile_pk=None):
        fp = self._get_finance_profile(user_pk, profile_pk, finance_profile_pk)

        rows = get_portfolio_stocks(fp, pk)
        if not rows:
            return Response({"error": "No data"}, status=status.HTTP_404_NOT_FOUND)

        structure = {r["ticker"]: r["number_of_shares"] for r in rows}
        series = portfolio_value_series(structure)
        if not series:
            return Response({"error": "Cannot build series"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response(series, status=status.HTTP_200_OK)


# ------------------------------------------------------------------ #
# ancillary view‑sets
# ------------------------------------------------------------------ #
class PortfolioStockViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PortfolioStock.objects.all()
    serializer_class = PortfolioStockSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]


class WatchlistStockViewSet(viewsets.ModelViewSet):
    queryset = WatchlistStock.objects.all()
    serializer_class = WatchlistStockSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        return self.queryset.filter(portfolio__pk=self.kwargs.get("stock_portfolio_pk"))