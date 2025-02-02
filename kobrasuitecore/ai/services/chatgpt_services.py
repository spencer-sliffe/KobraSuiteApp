import json
import logging
import re
import requests
from django.conf import settings
from functools import lru_cache
from ai.models import ChatLog

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
        messages = [{"role": "developer", "content": "You are a helpful assistant."}]
        for item in context_messages:
            if item["role"] == "user":
                messages.append({"role": "user", "content": item["content"]})
            else:
                messages.append({"role": "assistant", "content": item["content"]})
        messages.append({"role": "user", "content": message})
        payload = {"model": MODEL_ID, "messages": messages}
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
    prompt = (
        "You are a course verification assistant with access to up-to-date official course catalogs of universities. "
        "Your task is to verify if the provided course details exist and are correct. Use the official course catalog information for the specified university. "
        "If the university is 'University of Kansas', assume that the following course exists:\n"
        "  - Course Code: EECS168\n"
        "  - Official Course Title: 'Introduction to Programming I'\n"
        "  - Department: EECS\n"
        "  - Professor Last Name: Gibbons (if provided)\n"
        "  - Typically offered in the FALL semester\n\n"
        "When verifying the course, if there are minor variations in the course title (for example, 'Intro to Programming 1'), "
        "you should correct the title to the official version. Also, if any field (other than the course code) is slightly off, "
        "provide the corrected value along with a human-readable explanation in a 'feedback' field.\n\n"
        "The course details to verify are as follows:\n"
        f"University Name: {university_name}\n"
        f"Course Code: {course_code}\n"
        f"Course Title: {course_title}\n"
        f"Department (as abbreviation, e.g., EECS, BUS, WGSS): {department}\n"
        f"Professor Last Name: {professor_last_name}\n"
        f"Semester Type (WINTER, SPRING, SUMMER, FALL): {semester_type}\n\n"
        "Instructions:\n"
        "1. If the provided Course Code does not exist in the official course catalog, respond exactly with:\n"
        '   {"foundExactMatch": false, "correctedCourseData": null, "message": "Course code does not exist at the University.", "feedback": "Course code not found."}\n\n'
        "2. If the Course Code exists but one or more other fields (Course Title, Professor Last Name, Department, Semester Type) are incorrect, "
        "provide the corrected values in 'correctedCourseData', set foundExactMatch to false, and include a 'feedback' field explaining which fields were corrected. "
        "For example: 'Not all fields were correct: course title corrected from <input> to <corrected>.'\n\n"
        "3. If all provided details are correct as per the official course catalog, respond with foundExactMatch true, include the verified details in "
        "'correctedCourseData', and set 'feedback' to 'Course verified successfully.'\n\n"
        "Your response must be strictly in JSON format without any additional explanation or text."
    )
    response_text = communicate_with_openai(prompt, [])
    return _parse_chatgpt_response(response_text)


def _normalize_corrected_data(corr):
    new_corr = {}
    code = corr.get("courseCode") or corr.get("course_code")
    title = corr.get("course_title") or corr.get("title")
    prof = corr.get("professor_last_name") or corr.get("professor")
    dep = corr.get("department")
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
            "message": "No matching or similar course found.",
            "feedback": ""
        }
    try:
        data = json.loads(snippet)
        found_exact_match = data.get("foundExactMatch", False)
        corrected_data = data.get("correctedCourseData")
        feedback = data.get("feedback", "")
        if corrected_data:
            corrected_data = _normalize_corrected_data(corrected_data)
        return {
            "foundExactMatch": found_exact_match,
            "correctedCourseData": corrected_data,
            "message": data.get("message", ""),
            "feedback": feedback
        }
    except Exception:
        pass
    import ast
    try:
        data = ast.literal_eval(snippet)
        found_exact_match = data.get("foundExactMatch", False)
        corrected_data = data.get("correctedCourseData")
        feedback = data.get("feedback", "")
        if corrected_data:
            corrected_data = _normalize_corrected_data(corrected_data)
        return {
            "foundExactMatch": found_exact_match,
            "correctedCourseData": corrected_data,
            "message": data.get("message", ""),
            "feedback": feedback
        }
    except Exception:
        return {
            "foundExactMatch": False,
            "correctedCourseData": None,
            "message": "Could not parse course data.",
            "feedback": ""
        }
