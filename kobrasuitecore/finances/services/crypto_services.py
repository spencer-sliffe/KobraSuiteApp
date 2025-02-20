"""
------------------Prologue--------------------
File Name: crypto_services.py
Path: kobrasuitecore/finances/services/crypto_services.py

Description:
Implements core logic for managing crypto portfolios, including creation and deletion of
crypto holdings. Supports atomic transactions and queries to external APIs for up-to-date
pricing data.

Input:
Requests to add/remove crypto assets from user portfolios, plus external data lookups
for real-time coin info.

Output:
Database operations on crypto portfolios and aggregated data about portfolio performance.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# /finances/services/crypto_services
import logging
from django.db import transaction
from finances.models import CryptoPortfolio, PortfolioCrypto
from finances.utils.crypto_utils import get_crypto_data


def get_or_create_crypto_portfolio(finance_profile):
    portfolio = CryptoPortfolio.objects.filter(profile=finance_profile).first()
    if not portfolio:
        portfolio = CryptoPortfolio.objects.create(profile=finance_profile)
    return portfolio


def add_crypto_to_portfolio(finance_profile, portfolio_id, crypto_id, ticker, units, price):
    try:
        with transaction.atomic():
            portfolio = CryptoPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
            if not portfolio:
                return False
            existing = PortfolioCrypto.objects.filter(portfolio=portfolio, crypto_id=crypto_id, ticker__iexact=ticker).first()
            if existing:
                total_units = existing.number_of_units + units
                total_cost = existing.number_of_units * existing.ppu_at_purchase + units * price
                avg_price = total_cost / total_units if total_units > 0 else 0
                existing.number_of_units = total_units
                existing.ppu_at_purchase = avg_price
                existing.save()
                return True
            PortfolioCrypto.objects.create(
                portfolio=portfolio,
                crypto_id=crypto_id,
                ticker=ticker.upper(),
                number_of_units=units,
                ppu_at_purchase=price
            )
            return True
    except Exception as e:
        logging.error(e)
        return False


def remove_crypto_from_portfolio(finance_profile, portfolio_id, crypto_id):
    try:
        portfolio = CryptoPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
        if not portfolio:
            return False
        obj = PortfolioCrypto.objects.filter(portfolio=portfolio, crypto_id=crypto_id).first()
        if obj:
            obj.delete()
            return True
        return False
    except Exception as e:
        logging.error(e)
        return False


def get_portfolio_cryptos(finance_profile, portfolio_id):
    portfolio = CryptoPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
    if not portfolio:
        return []
    qs = portfolio.cryptos.all()
    data = []
    for c in qs:
        fetched = get_crypto_data(c.crypto_id)
        cp = fetched.get('price') if fetched else 0
        val = cp * c.number_of_units
        invested = c.number_of_units * c.ppu_at_purchase
        pl = val - invested
        pct = (pl / invested) * 100 if invested != 0 else 0
        data.append({
            "crypto_id": c.crypto_id,
            "ticker": c.ticker,
            "number_of_units": c.number_of_units,
            "ppu_at_purchase": c.ppu_at_purchase,
            "current_price": cp,
            "current_value": val,
            "total_invested": invested,
            "profit_loss": pl,
            "profit_loss_percentage": pct
        })
    return data