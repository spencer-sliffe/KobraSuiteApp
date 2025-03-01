import requests
import yfinance as yf
import pandas as pd


def get_current_stock_price(ticker):
    try:
        df = yf.Ticker(ticker).history(period='1d')
        if df.empty:
            return None
        return float(df['Close'].iloc[-1])
    except:
        return None


def get_stock_price_at_date(ticker, date):
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


def check_stock_validity(ticker):
    try:
        info = yf.Ticker(ticker).info
        if info.get('regularMarketOpen') is not None:
            return True
        return False
    except:
        return False


def get_stock_results_data(ticker):
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
    try:
        df = yf.Ticker(ticker).history(period='5y')
        if df.empty:
            return None
        df.reset_index(inplace=True)
        return df[['Date','Open','High','Low','Close','Volume']].tail(60).to_dict(orient='records')
    except:
        return None


def get_hot_stocks(api_key, budget=None):
    url = 'https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-movers'
    headers = {'X-RapidAPI-Key': api_key, 'X-RapidAPI-Host': 'apidojo-yahoo-finance-v1.p.rapidapi.com'}
    params = {'region':'US','lang':'en-US','count':'50','start':'0'}
    try:
        r = requests.get(url, headers=headers, params=params)
        d = r.json()
        hot = []
        for item in d.get('finance',{}).get('result',[]):
            if item.get('title') == 'Day Gainers':
                for q in item.get('quotes',[]):
                    sym = q.get('symbol')
                    if sym:
                        cp = get_current_stock_price(sym)
                        if cp is not None:
                            if budget is None or cp <= budget:
                                hot.append({'ticker': sym,'close_price':cp})
        return hot[:10]
    except:
        return []


def get_news_articles(api_key, query='stock market', page=1):
    try:
        url = 'https://newsapi.org/v2/everything'
        params = {
            'apiKey': api_key,
            'q': query,
            'language':'en',
            'sortBy':'publishedAt',
            'pageSize':10,
            'page':page
        }
        r = requests.get(url, params=params)
        if r.status_code == 200:
            return r.json()
        return {}
    except:
        return {}