# school/services/assignment_service.py

import logging
from django.db import transaction
from rest_framework import status
from ..models import Assignment, Submission

logger = logging.getLogger(__name__)


def create_assignment(validated_data):
    try:
        with transaction.atomic():
            assignment = Assignment.objects.create(**validated_data)
        logger.info(f"Created Assignment '{assignment.title}' for Course ID {assignment.course.id}")
        return assignment, status.HTTP_201_CREATED
    except Exception as e:
        logger.error(f"Error creating Assignment: {e}")
        raise


def get_submissions_for_assignment(assignment):
    try:
        submissions = assignment.submissions.all().order_by('-submitted_at')
        return submissions
    except Exception as e:
        logger.error(f"Error retrieving submissions for Assignment ID {assignment.id}: {e}")
        raise


def submit_assignment(user, assignment, data):
    try:
        with transaction.atomic():
            submission, created = Submission.objects.get_or_create(
                student=user,
                assignment=assignment,
                defaults={
                    'text_answer': data.get('text_answer', ''),
                    'answer_file': data.get('answer_file', None),
                    'comment': data.get('comment', ''),
                }
            )
            if not created:
                # Update existing submission
                updated = False
                if 'text_answer' in data and data['text_answer'] != submission.text_answer:
                    submission.text_answer = data['text_answer']
                    updated = True
                if 'answer_file' in data and data['answer_file'] != submission.answer_file:
                    submission.answer_file = data['answer_file']
                    updated = True
                if 'comment' in data and data['comment'] != submission.comment:
                    submission.comment = data['comment']
                    updated = True
                if updated:
                    submission.save()
                    logger.info(
                        f"Updated Submission ID {submission.id} for Assignment '{assignment.title}' by User '{user.username}'."
                    )
            else:
                logger.info(
                    f"Created Submission ID {submission.id} for Assignment '{assignment.title}' by User '{user.username}'."
                )
            return submission
    except Exception as e:
        logger.error(f"Error submitting Assignment '{assignment.id}' by User '{user.username}': {e}")
        raise


def update_submission(submission, validated_data):
    try:
        with transaction.atomic():
            for attr, value in validated_data.items():
                setattr(submission, attr, value)
            submission.save()
        logger.info(f"Updated Submission '{submission.id}' for Assignment '{submission.assignment.title}'.")
        return submission, status.HTTP_200_OK
    except Exception as e:
        logger.error(f"Error updating Submission '{submission.id}': {e}")
        raise


def delete_submission(submission):
    try:
        with transaction.atomic():
            submission.delete()
        logger.info(f"Deleted Submission ID {submission.id}")
        return {"detail": "Submission deleted."}, status.HTTP_200_OK
    except Exception as e:
        logger.error(f"Error deleting Submission '{submission.id}': {e}")
        raise