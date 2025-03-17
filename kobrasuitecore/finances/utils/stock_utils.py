"""
------------------Prologue--------------------
File Name: stock_utils.py
Path: kobrasuitecore\finances\utils\stock_utils.py

Description:
Extracts data from various external api and frameworks such as yfinance cleans the data 

Input:
Tickers and dates

Output:
Various data extracted from api and yfinance

Collaborators: SPENCER SLIFFE,Charlie Gillund
---------------------------------------------
"""
import requests
import yfinance as yf
import pandas as pd

#Function to get the stocks current price given the input of the ticker
def get_current_stock_price(ticker):
    try:
        df = yf.Ticker(ticker).history(period='1d')
        if df.empty:
            return None
        return float(df['Close'].iloc[-1])
    except:
        return None

# retrieves the stock price from yfinance at provided date Inputs : Ticker and date
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

# Checks if a stock is able to be retrieved from yfinance
def check_stock_validity(ticker):
    try:
        info = yf.Ticker(ticker).info
        if info.get('regularMarketOpen') is not None:
            return True
        return False
    except:
        return False

# This function returns all of the market info on the stock given its ticker and formats the data given from yfinance
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

# retrieves the info and chart 
def get_stock_chart(ticker):
    try:
        df = yf.Ticker(ticker).history(period='5y')
        if df.empty:
            return None
        df.reset_index(inplace=True)
        return df[['Date','Open','High','Low','Close','Volume']].tail(60).to_dict(orient='records')
    except:
        return None

# Uses yahoo-finance rapid api to retrieve market data then formats the data into a response
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

## Uses yahoo-finance rapid api to retrieve market new then formats the news into a JSON response

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