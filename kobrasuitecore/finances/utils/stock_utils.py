# ------------------Prologue--------------------
# File Name: stock_utils.py
# Path: kobrasuitecore\finances\utils\stock_utils.py
#
# Description:
# Extracts data from various external APIs and frameworks (e.g., yfinance)
# and cleans or filters that data.
#
# Input:
# Ticker symbols, optional dates, and API keys
#
# Output:
# Assorted stock and market data in Python data structures
#
# Collaborators: SPENCER SLIFFE, Charlie Gillund
# ---------------------------------------------

import requests
import yfinance as yf
import pandas as pd

def get_current_stock_price(ticker):
    try:
        t = yf.Ticker(ticker)
        fi = getattr(t, "fast_info", None) or {}
        price = fi.get("lastPrice")
        if price is not None:
            return float(price)

        # fallback to .history()
        df = t.history(period="1d")
        if not df.empty:
            return float(df["Close"].iloc[-1])
    except Exception:
        pass
    return None

def get_stock_price_at_date(ticker, date):
    """
    Fetches the stock price for a given ticker at or near a specific date.
    If date is None, falls back to the latest price.
    """
    if not date:
        return get_current_stock_price(ticker)
    try:
        start = (date - pd.Timedelta(days=1)).strftime('%Y-%m-%d')
        end = (date + pd.Timedelta(days=1)).strftime('%Y-%m-%d')
        df = yf.Ticker(ticker).history(start=start, end=end)
        if df.empty:
            return None
        df = df.reset_index()
        df['Diff'] = (df['Date'] - date).abs()
        row = df.loc[df['Diff'].idxmin()]
        return float(row['Close'])
    except:
        return None

def check_stock_validity(ticker: str) -> bool:
    """
    Returns True if Yahoo Finance can supply *any* price data
    for the given ticker. Works for AAPL, GOOGL, BRK.B, RDS‑A, etc.
    """
    try:
        tkr = ticker.strip().upper()
        yt  = yf.Ticker(tkr)

        # 1️⃣ fast_info is the quickest / cheapest
        fi = getattr(yt, "fast_info", None) or {}
        if fi.get("lastPrice") is not None:
            return True

        # 2️⃣ fall back to .info dict
        info = yt.info or {}
        if (
            info.get("regularMarketPrice") is not None
            or info.get("currentPrice") is not None
        ):
            return True

        # 3️⃣ pull a tiny bit of history as last resort
        hist = yt.history(period="1d", interval="1d")
        return not hist.empty

    except Exception:
        return False

def get_stock_results_data(ticker):
    """
    Retrieves detailed market data for a given ticker from yfinance.
    Returns None if data is unavailable.
    """
    try:
        info = yf.Ticker(ticker).info
        if not info.get('regularMarketPrice'):
            return None
        return {
            'ticker': info.get('symbol'),
            'name': info.get('shortName') or info.get('longName'),
            'sector': info.get('sector'),
            'industry': info.get('industry'),
            'market_cap': info.get('marketCap'),
            'price': info.get('currentPrice'),
            'previous_close': info.get('previousClose'),
            'open': info.get('open'),
            'day_low': info.get('dayLow'),
            'day_high': info.get('dayHigh'),
            'fifty_two_week_low': info.get('fiftyTwoWeekLow'),
            'fifty_two_week_high': info.get('fiftyTwoWeekHigh'),
            'volume': info.get('volume'),
            'average_volume': info.get('averageVolume'),
            'beta': info.get('beta'),
            'dividend_yield': info.get('dividendYield'),
            'trailing_pe': info.get('trailingPE'),
            'forward_pe': info.get('forwardPE'),
            'long_business_summary': info.get('longBusinessSummary'),
        }
    except:
        return None

def get_stock_chart(ticker):
    """
    Retrieves historical price data (5-year period) for a given ticker
    and returns the last 60 records as a list of dictionaries.
    """
    try:
        df = yf.Ticker(ticker).history(period='5y')
        if df.empty:
            return None
        df.reset_index(inplace=True)
        return df[['Date', 'Open', 'High', 'Low', 'Close', 'Volume']].tail(60).to_dict(orient='records')
    except:
        return None

def get_hot_stocks(api_key, budget=None):
    """
    Uses a RapidAPI endpoint to retrieve 'Day Gainers' data, then
    checks the current stock price. If budget is provided, filters
    out any stocks exceeding that budget. Returns up to 10 results.
    """
    url = 'https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-movers'
    headers = {'X-RapidAPI-Key': api_key, 'X-RapidAPI-Host': 'apidojo-yahoo-finance-v1.p.rapidapi.com'}
    params = {'region': 'US', 'lang': 'en-US', 'count': '50', 'start': '0'}
    try:
        r = requests.get(url, headers=headers, params=params)
        data = r.json()
        hot = []
        for item in data.get('finance', {}).get('result', []):
            if item.get('title') == 'Day Gainers':
                for quote in item.get('quotes', []):
                    sym = quote.get('symbol')
                    if sym:
                        cp = get_current_stock_price(sym)
                        if cp is not None:
                            if budget is None or cp <= budget:
                                hot.append({'ticker': sym, 'close_price': cp})
        return hot[:10]
    except:
        return []

def get_news_articles(api_key, query='stock market', page=1):
    """
    Retrieves news articles from the NewsAPI about the given query
    keyword. Defaults to 'stock market' if no query is provided.
    """
    try:
        url = 'https://newsapi.org/v2/everything'
        params = {
            'apiKey': api_key,
            'q': query,
            'language': 'en',
            'sortBy': 'publishedAt',
            'pageSize': 10,
            'page': page
        }
        r = requests.get(url, params=params)
        if r.status_code == 200:
            return r.json()
        return {}
    except:
        return {}

def get_name_and_change(ticker):
    info=yf.Ticker(ticker).info
    name=info.get('shortName') or info.get('longName') or ticker.upper()
    prev=info.get('previousClose') or 0
    price=info.get('regularMarketPrice') or prev
    pct=((price-prev)/prev*100) if prev else 0
    return name,float(pct)