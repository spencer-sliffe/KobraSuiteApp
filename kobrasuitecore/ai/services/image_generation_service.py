# File: ai/services/image_generation_service.py
import openai
import logging
from django.conf import settings

logger = logging.getLogger(__name__)

def generate_image(prompt: str) -> str:
    """
    Generate an image using DALL-E 3 via OpenAI API.
    Returns the URL of the generated image.
    Raises a ValueError if generation fails.
    """
    if not prompt:
        logger.error("Empty prompt provided to generate_image.")
        raise ValueError("Prompt must not be empty.")

    if not settings.OPENAI_API_KEY:
        logger.error("OpenAI API key is not configured.")
        raise ValueError("OpenAI API key is not configured.")

    openai.api_key = settings.OPENAI_API_KEY
    try:
        response = openai.Image.create(
            prompt=prompt,
            n=1,
            size="1024x1024",
            response_format="url",  # Ensure the response is a URL
            model="dall-e-3"
        )
        if "data" in response and isinstance(response["data"], list) and len(response["data"]) > 0:
            image_data = response["data"][0]
            image_url = image_data.get("url")
            if image_url:
                return image_url
            else:
                logger.error("No URL found in OpenAI response data.")
                raise ValueError("No URL found in OpenAI response data.")
        else:
            logger.error("Unexpected response format from OpenAI: %s", response)
            raise ValueError("Unexpected response format from OpenAI.")
    except Exception as e:
        logger.exception("Error generating image with prompt '%s': %s", prompt, str(e))
        raise ValueError("Image generation failed.") from e