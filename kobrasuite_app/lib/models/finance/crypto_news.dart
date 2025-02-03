class CryptoNews {
  final String title;
  final String description;
  final String url;
  final String publishedAt;
  final String? sourceName;

  CryptoNews({
    required this.title,
    required this.description,
    required this.url,
    required this.publishedAt,
    this.sourceName,
  });

  factory CryptoNews.fromJson(Map<String, dynamic> json) {
    return CryptoNews(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source'] != null ? json['source']['name'] : null,
    );
  }
}