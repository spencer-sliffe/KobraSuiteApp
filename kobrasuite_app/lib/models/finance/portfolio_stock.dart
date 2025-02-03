// lib/models/finance/portfolio_stock.dart
class PortfolioStock {
  final int id;
  final String ticker;
  final int numberOfShares;
  final double ppsAtPurchase;
  final String? createdAt;
  final String? updatedAt;

  PortfolioStock({
    required this.id,
    required this.ticker,
    required this.numberOfShares,
    required this.ppsAtPurchase,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioStock.fromJson(Map<String, dynamic> json) {
    return PortfolioStock(
      id: json['id'],
      ticker: json['ticker'] ?? '',
      numberOfShares: json['number_of_shares'] ?? 0,
      ppsAtPurchase: (json['pps_at_purchase'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      'number_of_shares': numberOfShares,
      'pps_at_purchase': ppsAtPurchase,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}