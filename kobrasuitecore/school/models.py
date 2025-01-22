# school/models.py
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.conf import settings
from django.utils import timezone
from .types import DiscussionScope, SEMESTER_CHOICES


class University(models.Model):
    name = models.CharField(max_length=255)
    country = models.CharField(max_length=100)
    domain = models.CharField(max_length=100)
    website = models.URLField(blank=True)
    state_province = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('name', 'country', 'domain')

    def __str__(self):
        return self.name

    @property
    def student_count(self):
        return self.school_profiles.count()

    @property
    def course_count(self):
        return self.courses.count()


class Course(models.Model):
    course_code = models.CharField(max_length=50, blank=True, null=True)
    professor_last_name = models.CharField(max_length=100, blank=True, null=True)
    title = models.CharField(max_length=200)
    semester_type = models.CharField(max_length=10, choices=SEMESTER_CHOICES, blank=True, null=True)
    semester_year = models.PositiveIntegerField(blank=True, null=True)
    department = models.CharField(max_length=100, blank=True, null=True)
    university = models.ForeignKey(
        University,
        on_delete=models.CASCADE,
        related_name='courses',
        null=True,
        blank=True
    )
    students = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='courses',
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['title']

    def __str__(self):
        return self.title

    @property
    def student_count(self):
        return self.students.count()

    @property
    def semester_display(self):
        if self.semester_type and self.semester_year:
            return f"{self.semester_type} {self.semester_year}"
        return ""


class Topic(models.Model):
    name = models.CharField(max_length=200, blank=True, default='Untitled Topic')
    course = models.ForeignKey(
        Course,
        on_delete=models.CASCADE,
        related_name='topics'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Topic: {self.name} (Course: {self.course.title})'


class Assignment(models.Model):
    course = models.ForeignKey(
        Course,
        on_delete=models.CASCADE,
        related_name='assignments'
    )
    title = models.CharField(max_length=200)
    due_date = models.DateTimeField()
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['due_date']

    def __str__(self):
        return f'{self.title} ({self.course.title})'


class Submission(models.Model):
    assignment = models.ForeignKey(
        Assignment,
        on_delete=models.CASCADE,
        related_name='submissions'
    )
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='submissions'
    )
    text_answer = models.TextField(blank=True, null=True)
    submitted_at = models.DateTimeField(auto_now_add=True)
    answer_file = models.FileField(upload_to='assignment_answers/', blank=True, null=True)
    comment = models.TextField(blank=True, null=True)

    class Meta:
        ordering = ['-submitted_at']

    def __str__(self):
        return f'Submission by {self.student.username} for {self.assignment.title}'


class StudyDocument(models.Model):
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='study_documents'
    )
    course = models.ForeignKey(
        Course,
        on_delete=models.CASCADE,
        related_name='documents'
    )
    topic = models.ForeignKey(
        Topic,
        on_delete=models.CASCADE,
        related_name='documents'
    )
    file = models.FileField(upload_to='study_documents/')
    title = models.CharField(max_length=200)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'Study Doc: {self.title}'


class DiscussionThread(models.Model):
    scope_content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        related_name='discussion_threads'
    )
    scope_object_id = models.PositiveIntegerField()
    scope = GenericForeignKey('scope_content_type', 'scope_object_id')
    title = models.CharField(max_length=200)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='discussion_threads'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['scope_content_type', 'scope_object_id']),
        ]

    def __str__(self):
        return self.title


class DiscussionPost(models.Model):
    thread = models.ForeignKey(
        DiscussionThread,
        on_delete=models.CASCADE,
        related_name='posts'
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='discussion_posts'
    )
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f'Post by {self.author.username} in {self.thread.title}'