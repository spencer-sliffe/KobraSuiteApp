# Generated by Django 5.1.4 on 2025-02-19 00:35

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hq', '0006_remove_moduleexperience_created_at_and_more'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='ModuleTask',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField()),
                ('module', models.CharField(choices=[('SCHOOL', 'School'), ('WORK', 'Work'), ('HOMELIFE', 'HomeLife'), ('FINANCE', 'Finance')], max_length=20)),
                ('task_number', models.IntegerField()),
                ('task_weight', models.FloatField(default=1.0)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='module_tasks', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'date', 'module', 'task_number')},
            },
        ),
    ]
