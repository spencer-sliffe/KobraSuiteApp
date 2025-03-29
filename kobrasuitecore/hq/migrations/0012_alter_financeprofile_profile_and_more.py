# Generated by Django 5.1.4 on 2025-03-29 17:53

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hq', '0011_remove_multiplier_multiplier_obj_content_type_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='financeprofile',
            name='profile',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='finance_profile', to='hq.userprofile'),
        ),
        migrations.AlterField(
            model_name='homelifeprofile',
            name='profile',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='homelife_profile', to='hq.userprofile'),
        ),
        migrations.AlterField(
            model_name='schoolprofile',
            name='profile',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='school_profile', to='hq.userprofile'),
        ),
        migrations.AlterField(
            model_name='wallet',
            name='profile',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='wallet', to='hq.userprofile'),
        ),
        migrations.AlterField(
            model_name='workprofile',
            name='profile',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='work_profile', to='hq.userprofile'),
        ),
    ]
