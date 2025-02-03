// lib/models/finance/watched_crypto.dart
class WatchedCrypto {
  final int id;
  final String cryptoId;
  final String ticker;
  final String createdAt;

  WatchedCrypto({
    required this.id,
    required this.cryptoId,
    required this.ticker,
    required this.createdAt,
  });

  factory WatchedCrypto.fromJson(Map<String, dynamic> json) {
    return WatchedCrypto(
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