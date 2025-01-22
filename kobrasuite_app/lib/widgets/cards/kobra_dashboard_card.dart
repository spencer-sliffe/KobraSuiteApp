// lib/widgets/kobra_dashboard_card.dart
import 'package:flutter/material.dart';

class KobraDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const KobraDashboardCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using InkWell inside a Material for ripple effect
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 250,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}