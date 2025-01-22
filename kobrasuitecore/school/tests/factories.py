# school/tests/factories.py

import factory
from factory.django import DjangoModelFactory
from faker import Faker
from django.utils import timezone

from school.models import (
    University, Course, Topic, Assignment, Submission,
    StudyDocument, DiscussionThread, DiscussionPost
)

fake = Faker()


class UniversityFactory(DjangoModelFactory):
    class Meta:
        model = University

    name = factory.LazyAttribute(lambda o: f"{fake.company()} University")
    country = factory.LazyAttribute(lambda o: fake.country())
    domain = factory.LazyAttribute(lambda o: fake.domain_name())
    website = factory.LazyAttribute(lambda o: f"https://{fake.domain_name()}")
    state_province = factory.LazyAttribute(lambda o: fake.state_abbr())


class CourseFactory(DjangoModelFactory):
    class Meta:
        model = Course

    course_code = factory.LazyAttribute(lambda o: f"{fake.pystr(min_chars=2, max_chars=4).upper()}{fake.random_int(min=100, max=999)}")
    professor_last_name = factory.LazyAttribute(lambda o: fake.last_name())
    title = factory.LazyAttribute(lambda o: f"{fake.word().title()} Course")
    description = factory.LazyAttribute(lambda o: fake.sentence())
    semester = factory.LazyAttribute(lambda o: fake.random_element(elements=("Spring", "Fall", "Winter")))
    university = factory.SubFactory(UniversityFactory)


class TopicFactory(DjangoModelFactory):
    class Meta:
        model = Topic

    name = factory.LazyAttribute(lambda o: f"Topic: {fake.word().title()}")
    course = factory.SubFactory(CourseFactory)


class AssignmentFactory(DjangoModelFactory):
    class Meta:
        model = Assignment

    course = factory.SubFactory(CourseFactory)
    title = factory.LazyAttribute(lambda o: f"{fake.word().title()} Assignment")
    description = factory.LazyAttribute(lambda o: fake.text(max_nb_chars=100))
    due_date = factory.LazyAttribute(lambda o: fake.future_datetime(end_date='+30d'))


class SubmissionFactory(DjangoModelFactory):
    class Meta:
        model = Submission

    assignment = factory.SubFactory(AssignmentFactory)
    student = factory.SubFactory("customer.tests.factories.UserFactory")
    text_answer = factory.LazyAttribute(lambda o: fake.paragraph())
    submitted_at = factory.LazyAttribute(lambda o: timezone.now())


class StudyDocumentFactory(DjangoModelFactory):
    class Meta:
        model = StudyDocument

    course = factory.SubFactory(CourseFactory)
    topic = factory.SubFactory(TopicFactory)
    title = factory.LazyAttribute(lambda o: f"Doc-{fake.word().title()}")
    description = factory.LazyAttribute(lambda o: fake.sentence())
    created_at = factory.LazyAttribute(lambda o: timezone.now())


class DiscussionThreadFactory(DjangoModelFactory):
    class Meta:
        model = DiscussionThread

    scope = factory.LazyAttribute(lambda o: fake.random_element(elements=("UNIVERSITY", "COURSE", "ASSIGNMENT")))
    scope_id = factory.LazyAttribute(lambda o: fake.random_int(min=1, max=999))
    title = factory.LazyAttribute(lambda o: f"Discussion: {fake.sentence(nb_words=3)}")
    created_by = factory.SubFactory("customer.tests.factories.UserFactory")


class DiscussionPostFactory(DjangoModelFactory):
    class Meta:
        model = DiscussionPost

    thread = factory.SubFactory(DiscussionThreadFactory)
    author = factory.SubFactory("customer.tests.factories.UserFactory")
    content = factory.LazyAttribute(lambda o: fake.text())