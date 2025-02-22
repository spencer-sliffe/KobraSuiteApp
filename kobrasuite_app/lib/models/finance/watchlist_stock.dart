class WatchlistStock {
  final int id;
  final String ticker;
  final String createdAt;

  WatchlistStock({
    required this.id,
    required this.ticker,
    required this.createdAt,
  });

  factory WatchlistStock.fromJson(Map<String, dynamic> json) {
    return WatchlistStock(
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