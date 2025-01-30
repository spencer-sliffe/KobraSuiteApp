from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from customer.permissions import IsOwnerOrAdmin
from finances.models import CryptoPortfolio, PortfolioCrypto, FavoriteCrypto, WatchlistCrypto
from finances.serializers.crypto_serializers import (
    CryptoPortfolioSerializer,
    PortfolioCryptoSerializer,
    FavoriteCryptoSerializer,
    WatchlistCryptoSerializer
)
from finances.services.crypto_services import (
    get_or_create_crypto_portfolio,
    add_crypto_to_portfolio,
    remove_crypto_from_portfolio,
    get_portfolio_cryptos
)
from finances.utils.crypto_utils import get_crypto_data
from hq.models import FinanceProfile


class CryptoPortfolioViewSet(viewsets.ModelViewSet):
    queryset = CryptoPortfolio.objects.all()
    serializer_class = CryptoPortfolioSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        user_pk = self.kwargs.get('user_pk')
        finance_profile_pk = self.kwargs.get('finance_profile_pk')
        return self.queryset.filter(profile__user__id=user_pk, profile__id=finance_profile_pk)

    def create(self, request, user_pk=None, finance_profile_pk=None):
        profile = get_object_or_404(FinanceProfile, pk=finance_profile_pk, user_id=user_pk)
        portfolio = get_or_create_crypto_portfolio(profile)
        serializer = self.get_serializer(portfolio)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['get'])
    def cryptos(self, request, pk=None, user_pk=None, finance_profile_pk=None):
        profile = get_object_or_404(FinanceProfile, pk=finance_profile_pk, user_id=user_pk)
        data = get_portfolio_cryptos(profile, pk)
        return Response(data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def add_crypto(self, request, pk=None, user_pk=None, finance_profile_pk=None):
        profile = get_object_or_404(FinanceProfile, pk=finance_profile_pk, user_id=user_pk)
        crypto_id = request.data.get('crypto_id')
        ticker = request.data.get('ticker')
        units = request.data.get('units')
        price = request.data.get('price')
        if not crypto_id or not ticker or units is None or price is None:
            return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)
        success = add_crypto_to_portfolio(profile, pk, crypto_id, ticker, float(units), float(price))
        if success:
            return Response({'message': f'{crypto_id} added.'}, status=status.HTTP_200_OK)
        return Response({'error': 'Failed to add crypto'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=True, methods=['delete'], url_path='remove_crypto/(?P<crypto_id>[^/.]+)')
    def remove_crypto(self, request, crypto_id=None, pk=None, user_pk=None, finance_profile_pk=None):
        profile = get_object_or_404(FinanceProfile, pk=finance_profile_pk, user_id=user_pk)
        success = remove_crypto_from_portfolio(profile, pk, crypto_id)
        if success:
            return Response({'message': f'{crypto_id} removed.'}, status=status.HTTP_200_OK)
        return Response({'error': 'Failed to remove crypto'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'], url_path='crypto_data')
    def crypto_data(self, request, user_pk=None, finance_profile_pk=None):
        cid = request.query_params.get('crypto_id')
        if not cid:
            return Response({'error': 'crypto_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        data = get_crypto_data(cid)
        if not data:
            return Response({'error': f'No data for {cid}'}, status=status.HTTP_404_NOT_FOUND)
        return Response(data, status=status.HTTP_200_OK)


class PortfolioCryptoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PortfolioCrypto.objects.all()
    serializer_class = PortfolioCryptoSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]


class FavoriteCryptoViewSet(viewsets.ModelViewSet):
    queryset = FavoriteCrypto.objects.all()
    serializer_class = FavoriteCryptoSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        crypto_portfolio_pk = self.kwargs.get('crypto_portfolio_pk')
        return self.queryset.filter(portfolio__pk=crypto_portfolio_pk)


class WatchlistCryptoViewSet(viewsets.ModelViewSet):
    queryset = WatchlistCrypto.objects.all()
    serializer_class = WatchlistCryptoSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]

    def get_queryset(self):
        crypto_portfolio_pk = self.kwargs.get('crypto_portfolio_pk')
        return self.queryset.filter(portfolio__pk=crypto_portfolio_pk)