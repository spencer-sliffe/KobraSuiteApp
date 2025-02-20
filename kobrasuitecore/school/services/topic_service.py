# school/services/topic_service.py
"""
------------------Prologue--------------------
File Name: topic_service.py
Path: kobrasuitecore/school/services/topic_service.py

Description:
Implements service functions for managing topics and study documents.
Handles creation, update, and deletion of topics and study documents using atomic transactions.
Logs key operations for monitoring and debugging purposes.

Input:
Validated topic and study document data from API requests.

Output:
Updated topic or study document objects along with corresponding HTTP status codes.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
import logging
from django.db import transaction
from rest_framework import status
from ..models import Topic, StudyDocument

logger = logging.getLogger(__name__)


def create_topic(topic_data):
    with transaction.atomic():
        topic = Topic.objects.create(**topic_data)
    logger.info(f"Created Topic '{topic.name}' for Course ID {topic.course.id}")
    return topic, status.HTTP_201_CREATED


def update_topic(topic, validated_data):
    for attr, value in validated_data.items():
        setattr(topic, attr, value)
    topic.save()
    logger.info(f"Updated Topic '{topic.name}' (ID: {topic.id})")
    return topic, status.HTTP_200_OK


def delete_topic(topic):
    topic.delete()
    logger.info(f"Deleted Topic ID {topic.id}")
    return {"detail": "Topic deleted."}, status.HTTP_200_OK


def create_study_document(document_data, author):
    topic = document_data.get('topic')
    course = topic.course
    with transaction.atomic():
        document = StudyDocument.objects.create(author=author, course=course, **document_data)
    logger.info(f"Created Study Document '{document.title}' for Topic ID {topic.id} and Course '{course.title}' by User '{author.username}'")
    return document, status.HTTP_201_CREATED


def update_study_document(document, validated_data):
    for attr, value in validated_data.items():
        setattr(document, attr, value)
    document.save()
    logger.info(f"Updated Study Document '{document.title}' (ID: {document.id})")
    return document, status.HTTP_200_OK


def delete_study_document(document):
    document.delete()
    logger.info(f"Deleted Study Document ID {document.id}")
    return {"detail": "Study Document deleted."}, status.HTTP_200_OK