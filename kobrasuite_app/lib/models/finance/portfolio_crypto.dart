// lib/models/finance/portfolio_crypto.dart
class PortfolioCrypto {
  final int id;
  final String cryptoId;
  final String ticker;
  final double numberOfUnits;
  final double ppuAtPurchase;
  final String? createdAt;
  final String? updatedAt;

  PortfolioCrypto({
    required this.id,
    required this.cryptoId,
    required this.ticker,
    required this.numberOfUnits,
    required this.ppuAtPurchase,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioCrypto.fromJson(Map<String, dynamic> json) {
    return PortfolioCrypto(
      id: json['id'],
      cryptoId: json['crypto_id'] ?? '',
      ticker: json['ticker'] ?? '',
      numberOfUnits: (json['number_of_units'] as num).toDouble(),
      ppuAtPurchase: (json['ppu_at_purchase'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crypto_id': cryptoId,
      'ticker': ticker,
      'number_of_units': numberOfUnits,
      'ppu_at_purchase': ppuAtPurchase,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}