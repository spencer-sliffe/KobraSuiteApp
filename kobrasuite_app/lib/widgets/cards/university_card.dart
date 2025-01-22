import 'package:flutter/material.dart';
import '../../../models/school/university.dart';

class UniversityCard extends StatelessWidget {
  final University university;
  final VoidCallback onTap;
  final Future<void> Function() onSetAsCurrent;

  const UniversityCard({
    Key? key,
    required this.university,
    required this.onTap,
    required this.onSetAsCurrent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  university.name.isEmpty ? '?' : university.name[0].toUpperCase(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(university.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${university.country} • ${university.domain}'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onSetAsCurrent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}