import 'package:flutter/material.dart';

class StocksTab extends StatelessWidget {
  const StocksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Stocks Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'View your portfolio and watchlist, and track your investments.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Portfolio Value: \$XX,XXX'),
            subtitle: const Text('Total value of your stock portfolio.'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Watchlist: X Stocks'),
            subtitle: const Text('Overview of stocks you are monitoring.'),
          ),
        ),
      ],
    );
  }
}