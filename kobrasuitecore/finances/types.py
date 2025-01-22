from django.db import models

class TransactionType(models.TextChoices):
    INCOME = "INCOME", "Income"
    EXPENSE = "EXPENSE", "Expense"
    TRANSFER = "TRANSFER", "Transfer"

class RecurringInterval(models.TextChoices):
    MONTHLY = "MONTHLY", "Monthly"
    YEARLY = "YEARLY", "Yearly"
    WEEKLY = "WEEKLY", "Weekly"
    NONE = "NONE", "None"

class DebtType(models.TextChoices):
    CREDIT_CARD = "CREDIT_CARD", "Credit Card"
    LOAN = "LOAN", "Loan"
    MORTGAGE = "MORTGAGE", "Mortgage"
    OTHER = "OTHER", "Other"
