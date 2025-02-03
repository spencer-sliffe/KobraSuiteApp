// lib/models/finance/watched_stock.dart
class WatchedStock {
  final int id;
  final String ticker;
  final String createdAt;

  WatchedStock({
    required this.id,
    required this.ticker,
    required this.createdAt,
  });

  factory WatchedStock.fromJson(Map<String, dynamic> json) {
    return WatchedStock(
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