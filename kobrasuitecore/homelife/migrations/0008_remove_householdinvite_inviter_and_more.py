# Generated by Django 4.2.20 on 2025-04-26 18:10

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('homelife', '0007_rename_medications_pet_medication_instructions_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='householdinvite',
            name='inviter',
        ),
        migrations.RemoveField(
            model_name='householdinvite',
            name='redeemed_at',
        ),
        migrations.RemoveField(
            model_name='householdinvite',
            name='redeemed_by',
        ),
    ]
