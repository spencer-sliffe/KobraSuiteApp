"""
------------------Prologue--------------------
File Name: misc_invest_views.py
Path: kobrasuitecore/finances/views/misc_invest_views.py

Description:
Provides endpoints covering miscellaneous investment functionalities, such as retrieving
stock or crypto data, fetching market movers, generating predictions, and returning
financial or news information.

Input:
Various query parameters for stock/crypto info, predictions, or market updates.

Output:
Aggregated or computed investment data, including predictions and news articles.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""

import os
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from finances.utils.stock_utils import (
    get_stock_results_data,
    get_stock_chart,
    get_hot_stocks,
    get_news_articles
)
from finances.services.stock_prediction_services import get_predictions


class MiscInvestViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['get'])
    def stock_data(self, request):
        ticker = request.query_params.get('ticker')
        if not ticker:
            return Response({'error': 'Missing ticker'}, status=status.HTTP_400_BAD_REQUEST)
        data = get_stock_results_data(ticker)
        if not data:
            return Response({'error': f'No data found for {ticker}'}, status=status.HTTP_404_NOT_FOUND)
        return Response(data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def stock_chart(self, request):
        ticker = request.query_params.get('ticker', 'AAPL')
        chart = get_stock_chart(ticker)
        if not chart:
            return Response({'error': 'Could not generate chart.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(chart, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def predictions(self, request):
        ticker = request.query_params.get('ticker', 'AAPL')
        MACD = request.query_params.get('MACD', 'false') == 'true'
        RSI = request.query_params.get('RSI', 'false') == 'true'
        SMA = request.query_params.get('SMA', 'false') == 'true'
        EMA = request.query_params.get('EMA', 'false') == 'true'
        ATR = request.query_params.get('ATR', 'false') == 'true'
        BBands = request.query_params.get('BBands', 'false') == 'true'
        VWAP = request.query_params.get('VWAP', 'false') == 'true'
        res = get_predictions(ticker, MACD=MACD, RSI=RSI, SMA=SMA, EMA=EMA, ATR=ATR, BBands=BBands, VWAP=VWAP)
        if not res:
            return Response({'error': 'Could not generate predictions'}, status=status.HTTP_400_BAD_REQUEST)
        return Response(res, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def hot_stocks(self, request):
        key = os.environ.get('RAPIDAPI_KEY')
        if not key:
            return Response({'error': 'No RapidAPI key found'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        user = request.user
        budget = 0
        if hasattr(user, 'finance_profile'):
            budget = user.finance_profile.budget
        hot = get_hot_stocks(key, budget)
        return Response(hot, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def news(self, request):
        query = request.query_params.get('query', 'stock market')
        page = request.query_params.get('page', 1)
        try:
            page = int(page)
        except:
            page = 1
        key = os.environ.get('NEWS_API_KEY')
        if not key:
            return Response({'error': 'No NEWS_API_KEY found'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        articles = get_news_articles(key, query, page)
        return Response(articles, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def stock_news(self, request):
        key = os.environ.get('NEWS_API_KEY')
        if not key:
            return Response({'error': 'No NEWS_API_KEY found'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        q = request.query_params.get('q', 'stocks')
        pg = request.query_params.get('page', 1)
        try:
            pg = int(pg)
        except:
            pg = 1
        articles = get_news_articles(key, q, pg)
        return Response(articles, status=status.HTTP_200_OK)