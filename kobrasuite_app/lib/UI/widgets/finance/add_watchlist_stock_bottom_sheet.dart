import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AddWatchlistStockState { initial, adding, added }

class AddWatchlistStockBottomSheet extends StatefulWidget {
  const AddWatchlistStockBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddWatchlistStockBottomSheet> createState() =>
      _AddWatchlistStockBottomSheetState();
}

class _AddWatchlistStockBottomSheetState
    extends State<AddWatchlistStockBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tickerController = TextEditingController();

  AddWatchlistStockState _state = AddWatchlistStockState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  Future<void> _addWatchlistStock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddWatchlistStockState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual API call result.

    if (success) {
      setState(() {
        _state = AddWatchlistStockState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add watchlist stock.';
        _state = AddWatchlistStockState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddWatchlistStockState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding watchlist stock...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddWatchlistStockState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Watchlist stock added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ticker field
            TextFormField(
              controller: _tickerController,
              decoration: const InputDecoration(labelText: 'Ticker'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter ticker' : null,
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddWatchlistStockState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddWatchlistStockState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addWatchlistStock,
          child: const Text('Add Stock'),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Watchlist Stock',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            ),
          ],
        ),
      ),
    );
  }
}