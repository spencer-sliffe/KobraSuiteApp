class BankAccount {
  final int id;
  final int profile;
  final String accountName;
  final String accountNumber;
  final String institutionName;
  final double balance;
  final String currency;
  final String? lastSynced;
  final String? createdAt;
  final String? updatedAt;

  BankAccount({
    required this.id,
    required this.profile,
    required this.accountName,
    required this.accountNumber,
    required this.institutionName,
    required this.balance,
    required this.currency,
    this.lastSynced,
    this.createdAt,
    this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      profile: json['profile'],
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      institutionName: json['institution_name'] ?? '',
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      lastSynced: json['last_synced'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': profile,
      'account_name': accountName,
      'account_number': accountNumber,
      'institution_name': institutionName,
      'balance': balance,
      'currency': currency,
      'last_synced': lastSynced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}