from rest_framework import serializers

from hq.models import SchoolProfile
from school.models import Course
from school.serializers.university_serializers import UniversitySerializer


class SchoolProfileSerializer(serializers.ModelSerializer):
    university_detail = UniversitySerializer(source='university', read_only=True)
    courses = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Course.objects.all(),
        required=False
    )

    class Meta:
        model = SchoolProfile
        fields = ['id', 'university', 'university_detail', 'courses']\

    def update(self, instance, validated_data):
        courses = validated_data.pop('courses', None)
        university = validated_data.pop('university', None)

        if university is not None:
            instance.university = university

        instance = super().update(instance, validated_data)

        if courses is not None:
            instance.courses.set(courses)

        instance.save()
        return instance
