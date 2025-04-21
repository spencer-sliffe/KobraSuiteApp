import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/finance/stock_portfolio_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddStockPortfolioState { initial, adding, added }

class AddStockPortfolioBottomSheet extends StatefulWidget {
  const AddStockPortfolioBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddStockPortfolioBottomSheet> createState() =>
      _AddStockPortfolioBottomSheetState();
}

class _AddStockPortfolioBottomSheetState
    extends State<AddStockPortfolioBottomSheet> {
  AddStockPortfolioState _state = AddStockPortfolioState.initial;
  String _errorFeedback = '';

  Future<void> _createPortfolio() async {
    setState(() {
      _state = AddStockPortfolioState.adding;
      _errorFeedback = '';
    });

    final success =
    await context.read<StockPortfolioProvider>().createPortfolio();

    if (success) {
      setState(() => _state = AddStockPortfolioState.added);

      // Close the bottom‑sheet after a brief toast‑time,
      // then hide the “Add Portfolio” button forever.
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.read<NavigationStore>().setAddStockPortfolioActive();
      }
    } else {
      setState(() {
        _errorFeedback = 'Failed to create portfolio.';
        _state = AddStockPortfolioState.initial;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_state) {
      case AddStockPortfolioState.initial:
        body = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create your one‑time stock portfolio?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_errorFeedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorFeedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _createPortfolio,
                child: const Text('Create Portfolio'),
              ),
            ),
          ],
        );
        break;

      case AddStockPortfolioState.adding:
        body = const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
        break;

      case AddStockPortfolioState.added:
        body = Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Portfolio created 🎉',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        );
        break;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: body,
      ),
    );
  }
}