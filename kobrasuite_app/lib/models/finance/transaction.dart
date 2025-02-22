class Transaction {
  final int id;
  final int profile;
  final int? bankAccount;
  final int? budgetCategory;
  final String transactionType;
  final double amount;
  final String? description;
  final String date;
  final String createdAt;

  Transaction({
    required this.id,
    required this.profile,
    this.bankAccount,
    this.budgetCategory,
    required this.transactionType,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      profile: json['profile'],
      bankAccount: json['bank_account'],
      budgetCategory: json['budget_category'],
      transactionType: json['transaction_type'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: json['date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile,
      'bank_account': bankAccount,
      'budget_category': budgetCategory,
      'transaction_type': transactionType,
      'amount': amount,
      'description': description,
      'date': date,
      'created_at': createdAt,
    };
  }
}