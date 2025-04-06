# school/utils/external_api.py

import logging
import requests
from typing import Tuple, Any, Union
from rest_framework import status

logger = logging.getLogger(__name__)

HIPOLABS_URL = 'http://universities.hipolabs.com/search'


def fetch_universities_from_hipolabs(
    name: str = None,
    country: str = None,
    timeout: int = 5
) -> Tuple[Union[dict, list], int]:
    params = {}
    if country:
        params['country'] = country
    if name:
        params['name'] = name

    logger.debug(f"[EXTERNAL_API] Fetching from Hipolabs with params={params}")
    try:
        response = requests.get(HIPOLABS_URL, params=params, timeout=timeout)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list):
                return data, status.HTTP_200_OK
            logger.warning("[EXTERNAL_API] Unexpected response structure.")
            return {"detail": "Unexpected response format from Hipolabs."}, status.HTTP_500_INTERNAL_SERVER_ERROR
        logger.error(f"[EXTERNAL_API] Error from Hipolabs: {response.status_code}, {response.text[:200]}")
        return {"detail": "Hipolabs error."}, response.status_code
    except requests.RequestException as e:
        logger.error(f"[EXTERNAL_API] RequestException: {e}")
        return {"detail": str(e)}, status.HTTP_503_SERVICE_UNAVAILABLE


def get_news_articles(api_key, query="American Universities", page=1):
    """
    Retrieves news articles from the NewsAPI about the given query
    keyword. Defaults to 'United States Universities' if no query is provided.
    We want to pass in the Users University to get the news articles specific to
    their University.
    """
    try:
        url = 'https://newsapi.org/v2/everything'
        params = {
            'apiKey': api_key,
            'q': query,
            'language': 'en',
            'sortBy': 'relevancy',
            'pageSize': 20,
            'page': page
        }
        r = requests.get(url, params=params)
        if r.status_code == 200:
            return r.json()  # Contains { 'articles': [...], ... }
        return {}
    except:
        return {}