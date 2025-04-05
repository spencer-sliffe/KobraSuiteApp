"""
Defines functions for searching or creating University entries based on external API data.
"""
from django.db.utils import IntegrityError
from rest_framework import status
from school.models import University
from school.utils.external_api import fetch_universities_from_hipolabs
import logging

logger = logging.getLogger(__name__)


def search_universities(name=None, country=None):
    """
    Searches universities via the external Hipolabs API. If a local match by name (icontains)
    is found, returns that entry's ID and stats. Otherwise, sets zero for student_count/course_count.
    """
    external_data, status_code = fetch_universities_from_hipolabs(name, country)
    if status_code != status.HTTP_200_OK:
        return {"detail": "Failed to fetch universities from external API."}, status_code

    # Limit to 30 results from the external data
    external_data = external_data[:30]
    external_unis = []

    for uni_data in external_data:
        uni_name = uni_data.get('name', '')
        country_str = uni_data.get('country', '')
        domains = uni_data.get('domains') or []
        websites = uni_data.get('web_pages') or []
        state_province = uni_data.get('state-province') or ''
        domain_str = domains[0] if domains else ''
        website_str = websites[0] if websites else ''

        # Single DB lookup
        local_uni = University.objects.filter(name__icontains=uni_name).first()
        if local_uni:
            external_unis.append({
                "id": local_uni.id,
                "name": local_uni.name,
                "country": local_uni.country,
                "domain": local_uni.domain,
                "website": local_uni.website,
                "state_province": local_uni.state_province,
                "student_count": local_uni.student_count,
                "course_count": local_uni.course_count,
            })
        else:
            external_unis.append({
                "id": 0,
                "name": uni_name,
                "country": country_str,
                "domain": domain_str,
                "website": website_str,
                "state_province": state_province,
                "student_count": 0,
                "course_count": 0,
            })

    return external_unis, status.HTTP_200_OK


def add_university_to_db(name, country):
    """
    Attempts to locate a matching university from the external data by name and country,
    and create or retrieve it in the local database. Raises ValueError if none is found
    or if external API is unavailable.
    """
    external_data, status_code = fetch_universities_from_hipolabs(name=name, country=country)
    if status_code != status.HTTP_200_OK:
        raise ValueError("Unable to fetch university data from external API.")

    name_lower = name.strip().lower()
    country_lower = country.strip().lower()

    for uni_data in external_data:
        if (uni_data.get('name', '').strip().lower() == name_lower and
                uni_data.get('country', '').strip().lower() == country_lower):
            uni_name = uni_data.get('name', '')
            country_str = uni_data.get('country', '')
            domains = uni_data.get('domains') or []
            websites = uni_data.get('web_pages') or []
            state_province = uni_data.get('state-province') or ''
            domain_str = domains[0] if domains else ''
            website_str = websites[0] if websites else ''

            try:
                university, created = University.objects.get_or_create(
                    name=uni_name,
                    country=country_str,
                    domain=domain_str,
                    defaults={"website": website_str, "state_province": state_province}
                )
                if created:
                    logger.info(
                        f"Created new University '{uni_name}' in '{country_str}' "
                        f"using domain '{domain_str}'."
                    )
                return university
            except IntegrityError:
                logger.warning(
                    f"Duplicate university for (name='{uni_name}', "
                    f"country='{country_str}', domain='{domain_str}')."
                )
                return University.objects.filter(
                    name=uni_name,
                    country=country_str,
                    domain=domain_str
                ).first()

    raise ValueError("University not found in external API.")