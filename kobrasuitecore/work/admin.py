from django.contrib import admin
from .models import Team, Project, WorkTask, Timesheet, Meeting, MeetingNote

@admin.register(Team)
class TeamAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at')
    search_fields = ('name',)
    filter_horizontal = ('members',)

@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'team', 'start_date', 'end_date', 'is_active')
    search_fields = ('name', 'team__name')
    list_filter = ('is_active', 'start_date', 'end_date')

@admin.register(WorkTask)
class WorkTaskAdmin(admin.ModelAdmin):
    list_display = ('title', 'project', 'assignee', 'status', 'priority', 'due_date', 'created_at')
    search_fields = ('title', 'project__name', 'assignee__username')
    list_filter = ('status', 'priority', 'due_date', 'created_at')

@admin.register(Timesheet)
class TimesheetAdmin(admin.ModelAdmin):
    list_display = ('user', 'project', 'task', 'date', 'hours_worked')
    search_fields = ('user__username', 'project__name', 'task__title')
    list_filter = ('date',)

@admin.register(Meeting)
class MeetingAdmin(admin.ModelAdmin):
    list_display = ('title', 'project', 'team', 'start_time', 'end_time', 'created_at')
    search_fields = ('title', 'project__name', 'team__name')
    list_filter = ('start_time', 'end_time', 'created_at')
    filter_horizontal = ('attendees',)

@admin.register(MeetingNote)
class MeetingNoteAdmin(admin.ModelAdmin):
    list_display = ('meeting', 'created_at', 'updated_at')
    search_fields = ('meeting__title',)
    list_filter = ('created_at', 'updated_at')
