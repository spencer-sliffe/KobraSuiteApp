class UniversityNews {
  final String title;
  final String summary;
  final String imageUrl;
  final String publishedAt;

  UniversityNews({
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
  });

  factory UniversityNews.fromJson(Map<String, dynamic> json) {
    return UniversityNews(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['image_url'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }
}