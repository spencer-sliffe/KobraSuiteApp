"""
------------------Prologue--------------------
File Name: stock_services.py
Path: kobrasuitecore/finances/services/stock_services.py

Description:
Handles the main business logic for stock portfolios, including adding and removing
stocks, retrieving current positions, and performing high-level portfolio analysis (e.g.,
expected returns, risk, Sharpe ratio).

Input:
User requests to manage stock holdings, plus real-time data lookups for stock prices.

Output:
Database operations reflecting updated portfolios, along with computed portfolio metrics.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
import logging
import numpy as np
import pandas as pd
import yfinance as yf
from datetime import datetime
from django.db import transaction
from finances.models import StockPortfolio, PortfolioStock
from finances.utils.stock_utils import get_current_stock_price, get_stock_price_at_date
from math import sqrt


def get_or_create_stock_portfolio(finance_profile):
    portfolio = StockPortfolio.objects.filter(profile=finance_profile).first()
    if not portfolio:
        portfolio = StockPortfolio.objects.create(profile=finance_profile)
    return portfolio


def add_stock_to_portfolio(finance_profile, portfolio_id, ticker, num_shares, purchase_date=None):
    try:
        with transaction.atomic():
            portfolio = StockPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
            if not portfolio:
                return False
            price = get_stock_price_at_date(ticker, purchase_date) or 0
            existing = PortfolioStock.objects.filter(portfolio=portfolio, ticker__iexact=ticker).first()
            if existing:
                total_shares = existing.number_of_shares + num_shares
                total_cost = (existing.number_of_shares * existing.pps_at_purchase) + (num_shares * price)
                avg = total_cost / total_shares if total_shares > 0 else 0
                existing.number_of_shares = total_shares
                existing.pps_at_purchase = avg
                existing.save()
                return True
            PortfolioStock.objects.create(
                portfolio=portfolio,
                ticker=ticker.upper(),
                number_of_shares=num_shares,
                pps_at_purchase=price
            )
            return True
    except Exception as e:
        logging.error(e)
        return False

def remove_stock_from_portfolio(finance_profile, portfolio_id, ticker):
    try:
        portfolio = StockPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
        if not portfolio:
            return False
        obj = PortfolioStock.objects.filter(portfolio=portfolio, ticker__iexact=ticker).first()
        if obj:
            obj.delete()
            return True
        return False
    except Exception as e:
        logging.error(e)
        return False

def get_portfolio_stocks(finance_profile, portfolio_id):
    portfolio = StockPortfolio.objects.filter(profile=finance_profile, pk=portfolio_id).first()
    if not portfolio:
        return []
    qs = portfolio.stocks.all()
    data = []
    for x in qs:
        cp = get_current_stock_price(x.ticker) or 0
        val = x.number_of_shares * cp
        invest = x.number_of_shares * x.pps_at_purchase
        pl = val - invest
        pct = (pl / invest) * 100 if invest != 0 else 0
        data.append({
            "ticker": x.ticker,
            "number_of_shares": x.number_of_shares,
            "pps_at_purchase": x.pps_at_purchase,
            "close_price": cp,
            "current_value": val,
            "total_invested": invest,
            "profit_loss": pl,
            "profit_loss_percentage": pct
        })
    return data


def portfolio_analysis(structure):
    try:
        now = datetime.now()
        start = now.replace(year=now.year - 5)
        tickers = list(structure.keys())
        shares = list(structure.values())
        cp = {}
        for t in tickers:
            p = get_current_stock_price(t)
            if p is None:
                return None
            cp[t] = p
        total_val = sum(shares[i] * cp[tickers[i]] for i in range(len(tickers)))
        if total_val == 0:
            return None
        weights = np.array([(shares[i]*cp[tickers[i]]) / total_val for i in range(len(tickers))])
        data = yf.download(tickers, start=start, end=now)['Adj Close']
        if isinstance(data, pd.Series):
            data = data.to_frame()
            data.columns = [tickers[0]]
        data.dropna(inplace=True)
        if data.empty:
            return None
        returns = data.pct_change().dropna()
        mu = returns.mean() * 252
        cov = returns.cov() * 252
        er = np.dot(weights, mu)
        var = np.dot(weights.T, np.dot(cov, weights))
        risk = sqrt(var)
        bench = yf.download('SPY', start=start, end=now)['Adj Close'].dropna()
        bench_ret = bench.pct_change().dropna()
        port_daily = (returns * weights).sum(axis=1)
        common_idx = port_daily.index.intersection(bench_ret.index)
        pdaily = port_daily.reindex(common_idx).dropna()
        bdaily = bench_ret.reindex(common_idx).dropna()
        alpha, beta = 0, 1
        if len(pdaily) > 10:
            b, a = np.polyfit(bdaily, pdaily, 1)
            alpha, beta = a, b
        risk_free = 0.02
        ex_ret = pdaily - risk_free / 252
        dn = ex_ret[ex_ret < 0]
        dn_dev = np.sqrt((dn**2).mean()) * np.sqrt(252) if not dn.empty else 1e-6
        sortino = (er - risk_free) / dn_dev
        cumret = (1 + pdaily).cumprod()
        peak = cumret.cummax()
        dd = (cumret - peak) / peak
        mdd = dd.min() if not dd.empty else 0
        sr = (er - risk_free) / risk if risk != 0 else 0
        def diversification_ratio(dat, wts):
            std_indiv = dat.std() * np.sqrt(252)
            weighted_vol = np.dot(wts, std_indiv)
            port_vol = np.sqrt(np.dot(wts.T, np.dot(dat.cov()*252, wts)))
            return weighted_vol / port_vol if port_vol != 0 else 1
        div = diversification_ratio(returns, weights)
        metrics = {
            'expected_return': er,
            'risk': risk,
            'sharpe_ratio': sr,
            'diversification_ratio': div,
            'alpha': alpha,
            'beta': beta,
            'sortino_ratio': sortino,
            'max_drawdown': mdd
        }
        return metrics
    except:
        return None