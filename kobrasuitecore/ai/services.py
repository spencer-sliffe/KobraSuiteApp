# File location: kobrasuitecore/kobrasuite/chatbot/services.py

import json
import logging
import re
import requests
from django.conf import settings
from functools import lru_cache
from .models import ChatLog

logger = logging.getLogger(__name__)
OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"
MODEL_ID = "gpt-4o"


@lru_cache(maxsize=1024)
def get_cached_response(prompt):
    return "This is a cached response."


def gather_conversation_for_user(user_id):
    logs = list(ChatLog.objects.filter(user_id=user_id).order_by('-timestamp')[:20])[::-1]
    conversation = []
    for log in logs:
        conversation.append({"role": "user", "content": log.user_message})
        conversation.append({"role": "assistant", "content": log.bot_response})
    return conversation


def communicate_with_openai(message, context_messages):
    try:
        messages = [
            {
                "role": "developer",
                "content": "You are a helpful assistant."
            }
        ]
        for item in context_messages:
            if item["role"] == "user":
                messages.append({"role": "user", "content": item["content"]})
            else:
                messages.append({"role": "assistant", "content": item["content"]})

        messages.append({"role": "user", "content": message})

        payload = {
            "model": MODEL_ID,
            "messages": messages,
        }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {settings.OPENAI_API_KEY}"
        }

        response = requests.post(OPENAI_API_URL, headers=headers, json=payload, timeout=60)
        if response.status_code != 200:
            logger.error(f"OpenAI API returned status {response.status_code}: {response.text}")
            return "I'm sorry, I couldn't process that right now."

        data = response.json()
        if "choices" not in data or len(data["choices"]) == 0:
            logger.error(f"OpenAI response did not contain choices: {data}")
            return "I'm sorry, I couldn't process that right now."

        return data["choices"][0]["message"].get("content", "I'm sorry, I couldn't process that.")
    except Exception as e:
        logger.error(f"Error communicating with OpenAI: {e}")
        return "I'm sorry, I couldn't process that right now."


def verify_course_existence(university_name, course_code, course_title, professor_last_name, department, semester_type):
    context = (
        "You are an assistant tasked with verifying whether a specific course is offered at a university. "
        "You have access to web search tools and university course catalogs to retrieve accurate information."
        "You have access to web search tools and university course catalogs to retrieve accurate information."
    )

    inputs = (
        f"University Name: {university_name}\n"
        f"Course Code: {course_code}\n"
        f"Course Title: {course_title}\n"
        f"Department: {department}\n"
        f"Professor Last Name: {professor_last_name}\n"
        f"Semester Type: {semester_type}\n"
    )

    output_expectations = (
        "Verify the professor exists at the university first. "
        "Verify the code and department second. "
        "Verify the course's title correctness third."
        "Then verify the semester type fourth."
        "Return the result as a JSON object. Follow these rules:\n"
        "1. If an exact match is found, return it with the appropriate professor last name:\n"
        '   {"foundExactMatch": true, "correctedCourseData": {"course_code": "<course_code>", ...}}\n'
        "2. If a partial match is found, return it with the appropriate fields corrected:\n"
        '   {"foundExactMatch": false, "correctedCourseData": {"course_code": "<corrected_course_code>", ...}}\n'
        'This is important for API accuracy: if you do find a partial match, please do submit the corrected details with:'
        '   {"foundExactMatch": false, "correctedCourseData": {"course_code": "<corrected_course_code>", ...}}\n'

        "details that do not match the course identified by the other "
        "details provided in 'correctedCourseData' if applicable."
    )

    notes = (
        "Ensure the 'department' is formatted as an abbreviation (e.g., EECS, BUS, WGSS).\n"
        "Use standard JSON formatting with double quotes. This is essential to API functionality.\n"
        "Do not explain how to verify the course; instead, directly provide the requested JSON response."
    )

    prompt = f"{context}\n\n{inputs}\n\n{output_expectations}\n\n{notes}"

    response_text = communicate_with_openai(prompt, [])

    print("Raw ChatGPT-like response:\n", response_text)

    return _parse_chatgpt_response(response_text)


def verify_course_existence(university_name, course_code, course_title, professor_last_name, department, semester_type):
    context = (
        "You are an assistant tasked with verifying whether a specific course is offered at a university. "
        "You have access to web search tools and university course catalogs to retrieve accurate information."
        "You have access to web search tools and university course catalogs to retrieve accurate information."
    )

    inputs = (
        f"University Name: {university_name}\n"
        f"Course Code: {course_code}\n"
        f"Course Title: {course_title}\n"
        f"Department: {department}\n"
        f"Professor Last Name: {professor_last_name}\n"
        f"Semester Type: {semester_type}\n"
    )

    output_expectations = (
        "Verify the code and department first. Then verify the title. Then verify the professor. "
        "Then verify the semester type."
        "Return the result as a JSON object. Follow these rules:\n"
        "1. If an exact match is found, return it with the appropriate professor last name:\n"
        '   {"foundExactMatch": true, "correctedCourseData": {"course_code": "<course_code>", ...}}\n'
        "2. If a partial match is found, return it with the appropriate fields corrected:\n"
        '   {"foundExactMatch": false, "correctedCourseData": {"course_code": "<corrected_course_code>", ...}}\n'
        'This is important for API accuracy: if you do find a partial match, please do submit the corrected details with:'
        '   {"foundExactMatch": false, "correctedCourseData": {"course_code": "<corrected_course_code>", ...}}\n'

        "details that do not match the course identified by the other "
        "details provided in 'correctedCourseData' if applicable."
    )

    notes = (
        "Ensure the 'department' is formatted as an abbreviation (e.g., EECS, BUS, WGSS).\n"
        "Use standard JSON formatting with double quotes. This is essential to API functionality.\n"
        "Do not explain how to verify the course; instead, directly provide the requested JSON response."
    )

    prompt = f"{context}\n\n{inputs}\n\n{output_expectations}\n\n{notes}"

    response_text = communicate_with_openai(prompt, [])

    print("Raw ChatGPT-like response:\n", response_text)

    return _parse_chatgpt_response(response_text)


def _normalize_corrected_data(corr):
    new_corr = {}
    code = corr.get("courseCode") or corr.get("course_code")
    title = corr.get("course_title") or corr.get("title")
    prof = corr.get("professor_last_name") or corr.get("professor")
    dep = corr.get("department") or corr.get("department")
    sem = corr.get("semester_type") or corr.get("semester")

    if code:
        new_corr["course_code"] = code
    if title:
        new_corr["course_title"] = title
    if prof:
        new_corr["professor_last_name"] = prof.split()[-1]
    if dep:
        new_corr["department"] = dep

    if sem:
        sem = sem.upper()
        valid_semesters = ["WINTER", "SPRING", "SUMMER", "FALL"]
        if sem not in valid_semesters:
            sem = "FALL"
        new_corr["semester_type"] = sem

    print(sem)
    return new_corr


def _parse_chatgpt_response(chatgpt_text):
    code_block_match = re.search(r'```json\s*(\{.*?\})\s*```', chatgpt_text, re.DOTALL)
    snippet = None
    if code_block_match:
        snippet = code_block_match.group(1).strip()

    if not snippet:
        brace_pattern = r'(\{.*?\})'
        blocks = re.findall(brace_pattern, chatgpt_text.replace('\n', ' '))
        if blocks:
            snippet = blocks[-1].strip()

    if not snippet:
        return {
            "foundExactMatch": False,
            "correctedCourseData": None,
            "message": "No matching or similar course found."
        }

    try:
        data = json.loads(snippet)
        found_exact_match = data.get("foundExactMatch", False)
        corrected_data = data.get("correctedCourseData", None)
        if corrected_data:
            corrected_data = _normalize_corrected_data(corrected_data)
        return {
            "foundExactMatch": found_exact_match,
            "correctedCourseData": corrected_data,
            "message": "Data parsed successfully."
        }
    except Exception:
        pass

    import ast
    try:
        data = ast.literal_eval(snippet)
        found_exact_match = data.get("foundExactMatch", False)
        corrected_data = data.get("correctedCourseData", None)
        if corrected_data:
            corrected_data = _normalize_corrected_data(corrected_data)
        return {
            "foundExactMatch": found_exact_match,
            "correctedCourseData": corrected_data,
            "message": "Data parsed successfully."
        }
    except Exception:
        return {
            "foundExactMatch": False,
            "correctedCourseData": None,
            "message": "Could not parse course data."
        }