# Generated by Django 5.1.4 on 2025-01-27 19:36

import django.db.models.deletion
import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('customer', '0003_financeprofile_workprofile'),
        ('finances', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='transaction',
            name='bank_account',
        ),
        migrations.RemoveField(
            model_name='bill',
            name='user',
        ),
        migrations.RemoveField(
            model_name='budget',
            name='user',
        ),
        migrations.RemoveField(
            model_name='budgetcategory',
            name='budget',
        ),
        migrations.RemoveField(
            model_name='transaction',
            name='budget_category',
        ),
        migrations.RemoveField(
            model_name='debt',
            name='user',
        ),
        migrations.RemoveField(
            model_name='savingsgoal',
            name='user',
        ),
        migrations.RemoveField(
            model_name='transaction',
            name='user',
        ),
        migrations.CreateModel(
            name='CryptoPortfolio',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('profile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='crypto_portfolios', to='customer.financeprofile')),
            ],
        ),
        migrations.CreateModel(
            name='FavoriteCrypto',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('crypto_id', models.CharField(max_length=30)),
                ('ticker', models.CharField(max_length=15)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='favorite_cryptos', to='finances.cryptoportfolio')),
            ],
        ),
        migrations.CreateModel(
            name='PortfolioCrypto',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('crypto_id', models.CharField(max_length=30)),
                ('ticker', models.CharField(max_length=15)),
                ('number_of_units', models.FloatField()),
                ('ppu_at_purchase', models.FloatField()),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='cryptos', to='finances.cryptoportfolio')),
            ],
        ),
        migrations.CreateModel(
            name='StockPortfolio',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('profile', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='stock_portfolios', to='customer.financeprofile')),
            ],
        ),
        migrations.CreateModel(
            name='PortfolioStock',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('ticker', models.CharField(max_length=12)),
                ('number_of_shares', models.IntegerField()),
                ('pps_at_purchase', models.FloatField()),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='stocks', to='finances.stockportfolio')),
            ],
        ),
        migrations.CreateModel(
            name='FavoriteStock',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('ticker', models.CharField(max_length=12)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='favorite_stocks', to='finances.stockportfolio')),
            ],
        ),
        migrations.CreateModel(
            name='WatchlistCrypto',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('crypto_id', models.CharField(max_length=30)),
                ('ticker', models.CharField(max_length=15)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='watchlist_cryptos', to='finances.cryptoportfolio')),
            ],
        ),
        migrations.CreateModel(
            name='WatchlistStock',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('ticker', models.CharField(max_length=12)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('portfolio', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='watchlist_stocks', to='finances.stockportfolio')),
            ],
        ),
        migrations.DeleteModel(
            name='BankAccount',
        ),
        migrations.DeleteModel(
            name='Bill',
        ),
        migrations.DeleteModel(
            name='Budget',
        ),
        migrations.DeleteModel(
            name='BudgetCategory',
        ),
        migrations.DeleteModel(
            name='Debt',
        ),
        migrations.DeleteModel(
            name='SavingsGoal',
        ),
        migrations.DeleteModel(
            name='Transaction',
        ),
    ]
