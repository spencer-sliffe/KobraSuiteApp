class StockNews {
  final String title;
  final String description;
  final String url;
  final String publishedAt;
  final String? sourceName;

  StockNews({
    required this.title,
    required this.description,
    required this.url,
    required this.publishedAt,
    this.sourceName,
  });

  factory StockNews.fromJson(Map<String, dynamic> json) {
    return StockNews(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source'] != null ? json['source']['name'] : null,
    );
  }
}