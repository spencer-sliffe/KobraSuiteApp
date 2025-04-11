class BankAccount {
  final int id;
  final int financeProfile;
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
    required this.financeProfile,
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
      // The server returns "finance_profile", so parse that instead of "profile".
      financeProfile: json['finance_profile'] ?? 0,
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      institutionName: json['institution_name'] ?? '',
      // If 'balance' is a string like "120.00", do double.parse(...).
      // Otherwise, if it's a numeric type, cast to num -> double.
      balance: double.parse(json['balance'].toString()),
      currency: json['currency'] ?? 'USD',
      lastSynced: json['last_synced'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Make sure you POST/PUT 'finance_profile' if the backend expects that:
      'finance_profile': financeProfile,
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