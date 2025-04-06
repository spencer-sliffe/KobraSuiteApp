import 'package:flutter/material.dart';
import '../../../../models/school/university_news.dart';

class UniversityNewsCard extends StatelessWidget {
  final UniversityNews news;
  const UniversityNewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      margin: const EdgeInsets.all(4), // Reduced margins to fit more on screen
      child: Container(
        width: 100, // A narrower default width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shorter image height so each card is more compact
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                news.imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 90,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.broken_image, size: 36, color: Colors.grey.shade600),
                ),
              ),
            ),
            // Less padding to save vertical space
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tighter text style, fewer lines
                  Text(
                    news.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.summary,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Smaller text size and color
                      Text(
                        news.publishedAt,
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[400]),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.secondary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}