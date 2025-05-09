# Generated by Django 5.1.4 on 2025-01-18 22:36

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('customer', '0001_initial'),
        ('school', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='schoolprofile',
            name='courses',
            field=models.ManyToManyField(blank=True, related_name='school_profiles', to='school.course'),
        ),
        migrations.AddField(
            model_name='schoolprofile',
            name='university',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='school_profiles', to='school.university'),
        ),
        migrations.AddField(
            model_name='schoolprofile',
            name='user',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='school_profile', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='securedocument',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='documents', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='user',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='profile', to=settings.AUTH_USER_MODEL),
        ),
    ]
