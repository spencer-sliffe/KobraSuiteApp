// lib/modules/finances/tabs/news_tab.dart

import 'package:flutter/material.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Financial News', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Breaking: Market Shifts'),
            subtitle: const Text('Details about major index changes...'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Stock X Surges 10%'),
            subtitle: const Text('Placeholder article summary.'),
          ),
        ),
        // ... more dummy headlines ...
      ],
    );
  }
}