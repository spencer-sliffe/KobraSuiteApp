"""
------------------Prologue--------------------
File Name: crypto_utils.py
Path: kobrasuitecore/finances/utils/crypto_utils.py

Description:
Offers utility functions for retrieving cryptocurrency data from external APIs (e.g.,
CoinGecko). Extracts current pricing, market cap, volume, and more for given coins.

Input:
Crypto coin identifiers used by external services.

Output:
Parsed data structures containing relevant crypto info (price, rank, volume, etc.).

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# /finances/utils/crypto_utils.py
import requests
from django.conf import settings


def get_crypto_data(crypto_id):
    try:
        url = f"https://api.coingecko.com/api/v3/coins/{crypto_id}"
        r = requests.get(url)
        if r.status_code != 200:
            return None
        data = r.json()
        price = data.get("market_data", {}).get("current_price", {}).get("usd")
        if price is None:
            return None
        return {
            "crypto_id": data.get("id", ""),
            "ticker": data.get("symbol", "").upper(),
            "name": data.get("name", ""),
            "price": price,
            "market_cap": data.get("market_data", {}).get("market_cap", {}).get("usd"),
            "percentage_change_24h": data.get("market_data", {}).get("price_change_percentage_24h"),
            "volume": data.get("market_data", {}).get("total_volume", {}).get("usd"),
            "rank": data.get("market_cap_rank")
        }
    except:
        return None