// File location: lib/UI/widgets/course_detail/topic_card.dart
import 'package:flutter/material.dart';
import '../../../../models/school/topic.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  const TopicCard({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(topic.name, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}