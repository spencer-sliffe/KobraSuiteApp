// lib/features/stocks/stocks_tab.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StocksTab extends StatelessWidget {
  const StocksTab({super.key});

  static final Uri _kobraStocksUri = Uri.parse('http://localhost:8080/');

  Future<void> _openKobraStocks() async {
    if (!await launchUrl(
      _kobraStocksUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_kobraStocksUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 60,
        child: ElevatedButton(
          onPressed: _openKobraStocks,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(letterSpacing: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: const Text('KOBRASTOCKS'),
        ),
      ),
    );
  }
}