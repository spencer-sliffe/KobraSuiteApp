from django.db.utils import IntegrityError
from rest_framework import status
from school.models import University
from school.utils.external_api import fetch_universities_from_hipolabs
import logging

logger = logging.getLogger(__name__)


def search_universities(name=None, country=None):
    external_data, status_code = fetch_universities_from_hipolabs(name, country)
    if status_code != status.HTTP_200_OK:
        return {"detail": "Failed to fetch universities from external API."}, status_code
    external_data = external_data[:30]
    external_unis = []
    for uni_data in external_data:
        uni_name = uni_data.get('name', '')
        country_str = uni_data.get('country', '')
        domains = uni_data.get('domains') or []
        websites = uni_data.get('web_pages') or []
        # Ensure state_province is not None
        state_province = uni_data.get('state-province') or ''
        domain_str = domains[0] if domains else ''
        website_str = websites[0] if websites else ''
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


async def add_university_to_db(name, country):
    external_data, status_code = fetch_universities_from_hipolabs(name=name, country=country)
    if status_code != status.HTTP_200_OK:
        raise ValueError("Unable to fetch university data from external API.")
    name_lower = name.strip().lower()
    country_lower = country.strip().lower()
    for uni_data in external_data:
        if uni_data.get('name', '').strip().lower() == name_lower and \
           uni_data.get('country', '').strip().lower() == country_lower:
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
                    logger.info(f"Created new University '{uni_name}' in '{country_str}' using domain '{domain_str}'.")
                return university
            except IntegrityError:
                logger.warning(f"Duplicate university for (name='{uni_name}', country='{country_str}', domain='{domain_str}').")
                return University.objects.get(name=uni_name, country=country_str, domain=domain_str)
    raise ValueError("University not found in external API.")