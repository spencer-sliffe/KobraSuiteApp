# Generated by Django 5.1.4 on 2025-03-27 20:14

import django.db.models.deletion
import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hq', '0010_merge_20250226_1839'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='multiplier',
            name='multiplier_obj_content_type',
        ),
        migrations.RemoveField(
            model_name='multiplier',
            name='multiplier_profile_content_type',
        ),
        migrations.RemoveField(
            model_name='multiplier',
            name='profile',
        ),
        migrations.RemoveField(
            model_name='financeprofile',
            name='user',
        ),
        migrations.RemoveField(
            model_name='homelifeprofile',
            name='user',
        ),
        migrations.RemoveField(
            model_name='schoolprofile',
            name='user',
        ),
        migrations.RemoveField(
            model_name='workprofile',
            name='user',
        ),
        migrations.AlterField(
            model_name='calendarevent',
            name='module_type',
            field=models.CharField(blank=True, choices=[('S', 'School'), ('W', 'Work'), ('H', 'HomeLife'), ('F', 'Finance')], max_length=20, null=True),
        ),
        migrations.AlterField(
            model_name='moduleexperience',
            name='module_type',
            field=models.CharField(choices=[('S', 'School'), ('W', 'Work'), ('H', 'HomeLife'), ('F', 'Finance')], max_length=1),
        ),
        migrations.AlterField(
            model_name='modulepopulation',
            name='module_type',
            field=models.CharField(choices=[('S', 'School'), ('W', 'Work'), ('H', 'HomeLife'), ('F', 'Finance')], max_length=1),
        ),
        migrations.AlterField(
            model_name='modulestatus',
            name='module_type',
            field=models.CharField(choices=[('S', 'School'), ('W', 'Work'), ('H', 'HomeLife'), ('F', 'Finance')], max_length=1),
        ),
        migrations.CreateModel(
            name='TaskCategoryProgress',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('module', models.CharField(choices=[('S', 'School'), ('W', 'Work'), ('H', 'HomeLife'), ('F', 'Finance')], max_length=1)),
                ('category_id', models.PositiveIntegerField()),
                ('completion_count', models.PositiveIntegerField(default=0)),
                ('last_renewed_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('profile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='task_category_progresses', to='hq.userprofile')),
            ],
            options={
                'unique_together': {('profile', 'module', 'category_id')},
            },
        ),
        migrations.CreateModel(
            name='TaskCategorySlots',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slots', models.BigIntegerField(default=0)),
                ('completed', models.BigIntegerField(default=0)),
                ('progress', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='slots', to='hq.taskcategoryprogress')),
            ],
        ),
        migrations.CreateModel(
            name='TaskPerformanceBounds',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slot_index', models.IntegerField(default=-1)),
                ('data', models.JSONField(blank=True, default=dict)),
                ('progress', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='performance_bounds', to='hq.taskcategoryprogress')),
            ],
            options={
                'unique_together': {('progress', 'slot_index')},
            },
        ),
        migrations.DeleteModel(
            name='ModuleTask',
        ),
        migrations.DeleteModel(
            name='Multiplier',
        ),
    ]
