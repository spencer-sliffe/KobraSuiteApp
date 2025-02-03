class StockPortfolio {
  final int id;
  final int financeProfile;
  final String createdAt;
  final String updatedAt;
  final List<dynamic>? stocks;

  StockPortfolio({
    required this.id,
    required this.financeProfile,
    required this.createdAt,
    required this.updatedAt,
    this.stocks,
  });

  factory StockPortfolio.fromJson(Map<String, dynamic> json) {
    return StockPortfolio(
      id: json['id'],
      financeProfile: json['profile'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      stocks: json['stocks'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile': financeProfile,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'stocks': stocks,
    };
  }
}