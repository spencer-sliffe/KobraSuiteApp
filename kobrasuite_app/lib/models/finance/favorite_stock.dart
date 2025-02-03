// lib/models/finance/favorite_stock.dart
class FavoriteStock {
  final int id;
  final String ticker;
  final String createdAt;

  FavoriteStock({
    required this.id,
    required this.ticker,
    required this.createdAt,
  });

  factory FavoriteStock.fromJson(Map<String, dynamic> json) {
    return FavoriteStock(
      id: json['id'],
      ticker: json['ticker'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      'created_at': createdAt,
    };
  }
}