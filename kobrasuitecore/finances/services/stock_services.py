import logging
from datetime import datetime
from math import sqrt

import numpy as np
import pandas as pd
import yfinance as yf
from django.db import transaction

from finances.models import PortfolioStock, StockPortfolio
from finances.utils.stock_utils import (
    get_current_stock_price,
    get_stock_price_at_date,
    get_name_and_change,
)


# ──────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────
def _get_portfolio(finance_profile):
    """
    Returns the single StockPortfolio for the given FinanceProfile,
    creating it if it doesn't exist.
    """
    portfolio, _ = StockPortfolio.objects.get_or_create(
        finance_profile=finance_profile
    )
    return portfolio


# ──────────────────────────────────────────────────────────────
# public API
# (The *portfolio_id* positional arg is kept for backward‑compat;
#   it is ignored internally.)
# ──────────────────────────────────────────────────────────────
def get_or_create_stock_portfolio(finance_profile):
    return _get_portfolio(finance_profile)


def add_stock_to_portfolio(finance_profile, _unused_id, ticker, num_shares, purchase_date=None):
    try:
        with transaction.atomic():
            portfolio = _get_portfolio(finance_profile)

            price = get_stock_price_at_date(ticker, purchase_date) \
                    or get_current_stock_price(ticker)
            if price is None:
                return False

            existing = PortfolioStock.objects.filter(
                portfolio=portfolio, ticker__iexact=ticker
            ).first()
            if existing:
                tot_shares = existing.number_of_shares + num_shares
                tot_cost   = existing.number_of_shares * existing.pps_at_purchase \
                             + num_shares * price
                existing.number_of_shares = tot_shares
                existing.pps_at_purchase  = tot_cost / tot_shares
                existing.save()
                return True

            PortfolioStock.objects.create(
                portfolio=portfolio,
                ticker=ticker.upper(),
                number_of_shares=num_shares,
                pps_at_purchase=price,
            )
            return True
    except Exception as e:
        logging.error(e)
        return False


def remove_stock_from_portfolio(finance_profile, _unused_id, ticker):
    try:
        portfolio = _get_portfolio(finance_profile)
        obj = PortfolioStock.objects.filter(
            portfolio=portfolio, ticker__iexact=ticker
        ).first()
        if obj:
            obj.delete()
            return True
        return False
    except Exception as e:
        logging.error(e)
        return False


def get_portfolio_stocks(finance_profile, _unused_id=None):
    portfolio = _get_portfolio(finance_profile)
    items = []
    for row in portfolio.stocks.all():
        cp = get_current_stock_price(row.ticker)
        if cp is None:
            continue

        invested      = row.number_of_shares * row.pps_at_purchase
        current_value = row.number_of_shares * cp
        pl            = current_value - invested
        pct           = pl / invested * 100 if invested else 0

        name, pct_change = get_name_and_change(row.ticker)

        items.append(
            {
                "ticker": row.ticker,
                "name": name,
                "number_of_shares": row.number_of_shares,
                "pps_at_purchase": row.pps_at_purchase,
                "close_price": cp,
                "current_value": current_value,
                "total_invested": invested,
                "profit_loss": pl,
                "profit_loss_percentage": pct,
                "percentage_change": pct_change,
            }
        )
    return items


def portfolio_analysis(structure):
    try:
        now = datetime.now()
        start = now.replace(year=now.year - 5)
        tickers = list(structure.keys())
        shares = list(structure.values())
        cp = {t: get_current_stock_price(t) for t in tickers}
        if any(v is None for v in cp.values()):
            return None
        total_val = sum(shares[i] * cp[tickers[i]] for i in range(len(tickers)))
        if total_val == 0:
            return None
        w = np.array([shares[i] * cp[tickers[i]] / total_val for i in range(len(tickers))])
        data = yf.download(tickers, start=start, end=now)["Adj Close"]
        if isinstance(data, pd.Series):
            data = data.to_frame()
            data.columns = [tickers[0]]
        data.dropna(inplace=True)
        if data.empty:
            return None
        r = data.pct_change().dropna()
        mu = r.mean() * 252
        cov = r.cov() * 252
        er = float(w.dot(mu))
        var = float(w.T.dot(cov).dot(w))
        risk = sqrt(var)
        bench = yf.download("SPY", start=start, end=now)["Adj Close"].pct_change().dropna()
        port_daily = (r * w).sum(axis=1)
        idx = port_daily.index.intersection(bench.index)
        pdaily = port_daily.loc[idx]
        bdaily = bench.loc[idx]
        alpha, beta = 0.0, 1.0
        if len(pdaily) > 10:
            b, a = np.polyfit(bdaily, pdaily, 1)
            alpha = float(a)
            beta = float(b)
        rf = 0.02
        sr = (er - rf) / risk if risk else 0
        ex = pdaily - rf / 252
        dn = ex[ex < 0]
        dn_dev = dn.pow(2).mean() ** 0.5 * 252 ** 0.5 if not dn.empty else 1e-6
        sortino = (er - rf) / dn_dev
        cum = (1 + pdaily).cumprod()
        peak = cum.cummax()
        mdd = float(((cum - peak) / peak).min()) if not cum.empty else 0
        std_indiv = r.std() * (252 ** 0.5)
        weighted_vol = w.dot(std_indiv)
        port_vol = sqrt(var)
        div = weighted_vol / port_vol if port_vol else 1
        return {
            "expected_return": er,
            "risk": risk,
            "sharpe_ratio": sr,
            "diversification_ratio": div,
            "alpha": alpha,
            "beta": beta,
            "sortino_ratio": sortino,
            "max_drawdown": mdd,
        }
    except Exception:
        return None


def portfolio_value_series(structure):
    tickers = list(structure.keys())
    shares = list(structure.values())
    frames = []
    for t in tickers:
        df = yf.Ticker(t).history(period="1y")[["Close"]]
        df.columns = [t]
        frames.append(df)
    if not frames:
        return None
    combined = pd.concat(frames, axis=1).ffill().dropna()
    for i, t in enumerate(tickers):
        combined[t] *= shares[i]
    combined["value"] = combined.sum(axis=1)
    combined.reset_index(inplace=True)
    return combined[["Date", "value"]].tail(60).to_dict(orient="records")


def build_chat_responses(metrics):
    if not metrics:
        return []
    er = metrics.get("expected_return", 0)
    risk = metrics.get("risk", 0)
    sr = metrics.get("sharpe_ratio", 0)
    res = []
    if sr > 1:
        res.append("Risk‑adjusted returns are strong.")
    elif sr < 0.5:
        res.append("Sharpe ratio indicates modest performance against risk.")
    if er > 0.08:
        res.append("Expected return exceeds 8%, reflecting growth orientation.")
    if risk > 0.25:
        res.append("Volatility is high; consider further diversification.")
    return res