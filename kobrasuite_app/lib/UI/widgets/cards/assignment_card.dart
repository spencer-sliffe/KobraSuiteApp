// File location: lib/UI/widgets/course_detail/assignment_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/school/assignment.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  const AssignmentCard({Key? key, required this.assignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.2)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Due: ${dateFormat.format(assignment.dueDate)}", style: Theme.of(context).textTheme.titleMedium),
            if (assignment.description != null && assignment.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  assignment.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}