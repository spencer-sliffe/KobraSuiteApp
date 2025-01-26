# Generated by Django 5.1.4 on 2025-01-25 21:29

import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('work', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.RemoveField(
            model_name='meetingnote',
            name='meeting',
        ),
        migrations.RemoveField(
            model_name='project',
            name='team',
        ),
        migrations.RemoveField(
            model_name='timesheet',
            name='project',
        ),
        migrations.RemoveField(
            model_name='worktask',
            name='project',
        ),
        migrations.RemoveField(
            model_name='team',
            name='members',
        ),
        migrations.RemoveField(
            model_name='timesheet',
            name='task',
        ),
        migrations.RemoveField(
            model_name='timesheet',
            name='user',
        ),
        migrations.RemoveField(
            model_name='worktask',
            name='assignee',
        ),
        migrations.CreateModel(
            name='WorkPlace',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('field', models.CharField(choices=[('TECHNOLOGY', 'Technology'), ('RETAIL', 'Retail'), ('AUTOMOBILE', 'Automobile'), ('FINANCE', 'Finance'), ('HEALTHCARE', 'Healthcare'), ('EDUCATION', 'Education'), ('REAL_ESTATE', 'Real Estate'), ('MEDIA', 'Media'), ('OTHER', 'Other')], default='OTHER', max_length=50)),
                ('website', models.URLField(blank=True, max_length=500, null=True)),
                ('invite_code', models.CharField(blank=True, max_length=20, unique=True)),
                ('identity_image', models.ImageField(blank=True, null=True, upload_to='workplace_identity/')),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('owner', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='owned_workplaces', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.DeleteModel(
            name='Meeting',
        ),
        migrations.DeleteModel(
            name='MeetingNote',
        ),
        migrations.DeleteModel(
            name='Project',
        ),
        migrations.DeleteModel(
            name='Team',
        ),
        migrations.DeleteModel(
            name='Timesheet',
        ),
        migrations.DeleteModel(
            name='WorkTask',
        ),
    ]
