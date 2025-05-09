"""
------------------Prologue--------------------
File Name: image_generation_service.py
Path: kobrasuitecore/ai/services/image_generation_service.py

Description:
Handles the generation of banner color palettes by querying the OpenAI API, parsing JSON responses,
and providing fallback defaults if prompts or configurations are invalid.

Input:
Color generation prompts from user requests.

Output:
Lists of hex color codes representing a color palette.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# File: ai/services/image_generation_service.py
import json
import logging
import re
from django.conf import settings
from ai.services.chatgpt_services import communicate_with_openai

logger = logging.getLogger(__name__)
FALLBACK_COLOR_PALETTE = ["#E8000D", "#0051BA"]


def generate_banner_colors(prompt: str) -> list:
    if not prompt:
        logger.error("Empty prompt provided to generate_banner_colors.")
        return FALLBACK_COLOR_PALETTE
    if not settings.OPENAI_API_KEY:
        logger.error("OpenAI API key is not configured.")
        return FALLBACK_COLOR_PALETTE

    system_prompt = (
        "You are an assistant that identifies the official color scheme for a university. "
        "Given the following prompt, return only a JSON array of hex color codes representing the primary colors associated with the university. "
        "For example: [\"#E8000D\", \"#0051BA\"]. Do not include any additional text."
    )
    full_prompt = f"{system_prompt}\nPrompt: {prompt}"

    try:
        response_text = communicate_with_openai(full_prompt, [])
        colors = _parse_colors_response(response_text)
        if colors and isinstance(colors, list) and all(isinstance(c, str) for c in colors):
            return colors
        logger.error("Invalid color palette received from ChatGPT: %s", response_text)
    except Exception as e:
        logger.exception("Error generating banner colors with prompt '%s': %s", prompt, str(e))
    return FALLBACK_COLOR_PALETTE


def _parse_colors_response(response_text: str):
    try:
        code_block_match = re.search(r'```json\s*($begin:math:display$[^$end:math:display$]+\])\s*```', response_text, re.DOTALL)
        snippet = None
        if code_block_match:
            snippet = code_block_match.group(1).strip()
        if not snippet:
            array_match = re.search(r'(\[[^\]]+\])', response_text)
            if array_match:
                snippet = array_match.group(1).strip()
        if snippet:
            return json.loads(snippet)
    except Exception:
        pass
    return None