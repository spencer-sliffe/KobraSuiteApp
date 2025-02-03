// lib/models/finance/favorite_crypto.dart
class FavoriteCrypto {
  final int id;
  final String cryptoId;
  final String ticker;
  final String createdAt;

  FavoriteCrypto({
    required this.id,
    required this.cryptoId,
    required this.ticker,
    required this.createdAt,
  });

  factory FavoriteCrypto.fromJson(Map<String, dynamic> json) {
    return FavoriteCrypto(
      id: json['id'],
      cryptoId: json['crypto_id'] ?? '',
      ticker: json['ticker'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crypto_id': cryptoId,
      'ticker': ticker,
      'created_at': createdAt,
    };
  }
}