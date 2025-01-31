# import os
# import logging
# import requests
# import json
# from django.conf import settings
# from google.oauth2 import service_account
# from google.auth.transport.requests import Request
# from notification.models import PushToken
#
# logger = logging.getLogger(__name__)
#
#
# def _get_access_token():
#     service_account_file = settings.GOOGLE_APPLICATION_CREDENTIALS
#     if not service_account_file or not os.path.isfile(service_account_file):
#         logger.error("Missing or invalid GOOGLE_APPLICATION_CREDENTIALS path.")
#         return None
#     scopes = ["https://www.googleapis.com/auth/firebase.messaging"]
#     try:
#         credentials = service_account.Credentials.from_service_account_file(
#             service_account_file, scopes=scopes
#         )
#         credentials.refresh(Request())
#         logger.debug("Successfully obtained FCM access token.")
#         return credentials.token
#     except Exception as e:
#         logger.exception("Failed to obtain FCM access token: %s", e)
#         return None
#
#
# def send_push_notification(user, title: str = None, body: str = None, data_payload=None, data_only=False) -> None:
#     if not data_only and not title and not body:
#         logger.warning("No title or body provided to send_push_notification.")
#         return
#
#     tokens = list(
#         user.push_tokens.filter(is_valid=True).values_list("token", flat=True)
#     )
#
#     logger.debug(f"Sending push notification to user {user.id} with tokens: {tokens}")
#
#     if not tokens:
#         logger.info(f"No valid tokens for user {user.id} ({user}).")
#         return
#
#     for token_str in tokens:
#         logger.debug(f"Preparing to send notification to token: {token_str}")
#         _send_fcm_httpv1(token_str, title, body, data_payload=data_payload, data_only=data_only)
#
#
# def _send_fcm_httpv1(device_token, title, body, data_payload=None, data_only=False):
#     access_token = _get_access_token()
#     if not access_token:
#         logger.error("No access token could be obtained. FCM request aborted.")
#         return
#     project_id = settings.FIREBASE_PROJECT_ID
#     url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
#     sanitized_data = {}
#     if data_payload:
#         for k, v in data_payload.items():
#             sanitized_data[str(k)] = str(v)
#     message = {
#         "message": {
#             "token": device_token,
#             "data": sanitized_data
#         }
#     }
#     if not data_only:
#         message["message"]["notification"] = {
#             "title": title,
#             "body": body
#         }
#     payload = message
#     headers = {
#         "Content-Type": "application/json",
#         "Authorization": f"Bearer {access_token}"
#     }
#     logger.debug(f"Sending FCM request to {url} with payload: {json.dumps(payload)}")
#     try:
#         response = requests.post(url, headers=headers, json=payload, timeout=5)
#         response.raise_for_status()
#         logger.debug(f"FCM v1 success to token={device_token}")
#     except requests.exceptions.HTTPError as http_err:
#         logger.error(f"FCM v1 push failed (HTTP {response.status_code}): {response.text}, token={device_token}")
#         if response.status_code in [404, 410]:
#             _invalidate_token(device_token)
#     except requests.exceptions.RequestException as ex:
#         logger.error("FCM v1 request error: %s", ex)
#
#
# def _invalidate_token(token_str):
#     logger.warning(f"Token {token_str} is invalid. Marking as invalid in DB.")
#     PushToken.objects.filter(token=token_str).update(is_valid=False)
#
#
# def remove_token(token_str):
#     updated = PushToken.objects.filter(token=token_str, is_valid=True).update(is_valid=False)
#     if updated:
#         logger.info(f"Manually invalidated token: {token_str}")
#     else:
#         logger.debug(f"Token not found or already invalid: {token_str}")