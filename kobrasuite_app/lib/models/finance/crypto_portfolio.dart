class CryptoPortfolio {
  final int id;
  final int financeProfile;
  final String createdAt;
  final String updatedAt;
  final List<dynamic>? cryptos;

  CryptoPortfolio({
    required this.id,
    required this.financeProfile,
    required this.createdAt,
    required this.updatedAt,
    this.cryptos,
  });

  factory CryptoPortfolio.fromJson(Map<String, dynamic> json) {
    return CryptoPortfolio(
      id: json['id'],
      financeProfile: json['profile'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      cryptos: json['cryptos'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': financeProfile,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cryptos': cryptos,
    };
  }
}