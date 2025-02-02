import 'package:flutter/material.dart';
import '../../../models/school/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                course.courseCode.isNotEmpty ? course.courseCode[0].toUpperCase() : '?',
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${course.courseCode} • ${course.professorLastName}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor)
          ],
        ),
      ),
    );
  }
}