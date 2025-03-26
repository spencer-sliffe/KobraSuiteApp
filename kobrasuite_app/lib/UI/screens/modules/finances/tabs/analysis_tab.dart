// lib/modules/finances/tabs/analysis_tab.dart

import 'package:flutter/material.dart';

class AnalysisTab extends StatelessWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Portfolio Analysis', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Expected Return: 8.5%'),
        const Text('Risk (Volatility): 12.3%'),
        const Text('Sharpe Ratio: 0.69'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.assessment),
          label: const Text('Run Full Analysis'),
        ),
      ],
    );
  }
}