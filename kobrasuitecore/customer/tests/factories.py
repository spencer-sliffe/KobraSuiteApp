# customer/tests/factories.py

import factory
from django.contrib.auth import get_user_model
from factory.django import DjangoModelFactory
from faker import Faker
from customer.models import Role, SecureDocument
from hq.models import UserProfile, SchoolProfile
from school.tests.factories import UniversityFactory

fake = Faker()
User = get_user_model()


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User

    username = factory.LazyAttribute(lambda x: fake.user_name())
    email = factory.LazyAttribute(lambda x: fake.email())
    password = factory.PostGenerationMethodCall('set_password', 'password123')


class RoleFactory(DjangoModelFactory):
    class Meta:
        model = Role

    name = factory.LazyAttribute(lambda x: fake.job())
    description = factory.LazyAttribute(lambda x: fake.sentence())


class UserProfileFactory(DjangoModelFactory):
    class Meta:
        model = UserProfile

    user = factory.SubFactory(UserFactory)
    date_of_birth = factory.LazyAttribute(lambda x: fake.date_of_birth(minimum_age=18, maximum_age=30))
    address = factory.LazyAttribute(lambda x: fake.address())


class SecureDocumentFactory(DjangoModelFactory):
    class Meta:
        model = SecureDocument

    user = factory.SubFactory(UserFactory)
    title = factory.LazyAttribute(lambda x: f"Document {fake.word()}")
    description = factory.LazyAttribute(lambda x: fake.text(max_nb_chars=50))


def generate_valid_phone_number():
    include_plus = fake.boolean()
    include_one = fake.boolean()

    num_digits = fake.random_int(min=9, max=15)
    digits = [str(fake.random_digit()) for _ in range(num_digits)]
    number = ''.join(digits)

    phone_number = ""
    if include_plus:
        phone_number += "+"
    if include_one:
        phone_number += "1"
    phone_number += number

    return phone_number[:17]


class SchoolProfileFactory(DjangoModelFactory):
    class Meta:
        model = SchoolProfile
    user = factory.SubFactory(UserFactory)
    university = factory.SubFactory(UniversityFactory)

    @factory.post_generation
    def courses(self, create, extracted, **kwargs):
        if not create:
            return
        if extracted:
            for course in extracted:
                self.courses.add(course)
