import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Enum for the form state.
enum AddPortfolioStockState { initial, adding, added }

class AddPortfolioStockBottomSheet extends StatefulWidget {
  const AddPortfolioStockBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddPortfolioStockBottomSheet> createState() =>
      _AddPortfolioStockBottomSheetState();
}

class _AddPortfolioStockBottomSheetState
    extends State<AddPortfolioStockBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _tickerController = TextEditingController();
  final TextEditingController _numberOfSharesController = TextEditingController();
  final TextEditingController _ppsAtPurchaseController = TextEditingController();

  AddPortfolioStockState _state = AddPortfolioStockState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _tickerController.dispose();
    _numberOfSharesController.dispose();
    _ppsAtPurchaseController.dispose();
    super.dispose();
  }

  Future<void> _addPortfolioStock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddPortfolioStockState.adding;
      _errorFeedback = "";
    });

    // Simulate an async service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual API/service call.

    if (success) {
      setState(() {
        _state = AddPortfolioStockState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add portfolio stock.';
        _state = AddPortfolioStockState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddPortfolioStockState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding portfolio stock...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddPortfolioStockState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Portfolio stock added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    // Build the form.
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
            // Ticker Field.
            TextFormField(
              controller: _tickerController,
              decoration: const InputDecoration(labelText: 'Ticker'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter ticker' : null,
            ),
            const SizedBox(height: 12),
            // Number of Shares.
            TextFormField(
              controller: _numberOfSharesController,
              decoration:
              const InputDecoration(labelText: 'Number of Shares'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter number of shares';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid integer';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Price per Share at Purchase.
            TextFormField(
              controller: _ppsAtPurchaseController,
              decoration:
              const InputDecoration(labelText: 'Price per Share at Purchase'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter price per share';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
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
    if (_state == AddPortfolioStockState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddPortfolioStockState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addPortfolioStock,
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
            Text('Add New Portfolio Stock',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            )
          ],
        ),
      ),
    );
  }
}