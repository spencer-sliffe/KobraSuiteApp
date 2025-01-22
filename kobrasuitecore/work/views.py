from rest_framework import viewsets
from .models import Team, Project, WorkTask

class TeamViewSet(viewsets.ModelViewSet):
    queryset = Team.objects.all()
    # serializer_class = TeamSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    # serializer_class = ProjectSerializer

class WorkTaskViewSet(viewsets.ModelViewSet):
    queryset = WorkTask.objects.all()
    # serializer_class = WorkTaskSerializer