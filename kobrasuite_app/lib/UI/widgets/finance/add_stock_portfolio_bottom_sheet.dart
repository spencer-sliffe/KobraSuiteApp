import 'package:flutter/material.dart';

enum AddStockPortfolioState { initial, adding, added }

class AddStockPortfolioBottomSheet extends StatefulWidget {
  const AddStockPortfolioBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddStockPortfolioBottomSheet> createState() =>
      _AddStockPortfolioBottomSheetState();
}

class _AddStockPortfolioBottomSheetState
    extends State<AddStockPortfolioBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _portfolioTitleController = TextEditingController();

  AddStockPortfolioState _state = AddStockPortfolioState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _portfolioTitleController.dispose();
    super.dispose();
  }

  Future<void> _createPortfolio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddStockPortfolioState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call. Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual service result.

   try {

    final result = await PortfolioService().createPortfolio(
      title: _portfolioTitleController.text.trim(),
    );
    
    setState(() {
      _state = AddStockPortfolioState.added;
    });
    
  } catch (e) {
    setState(() {
      _errorFeedback = 'Failed to create portfolio: ${e.toString()}';
      _state = AddStockPortfolioState.initial;
    });
  }
  Widget _buildContent() {
    if (_state == AddStockPortfolioState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating portfolio...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddStockPortfolioState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Portfolio created successfully.',
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
            // Portfolio Title Field
            TextFormField(
              controller: _portfolioTitleController,
              decoration: const InputDecoration(labelText: 'Portfolio Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a portfolio title';
                }
                return null;
              },
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddStockPortfolioState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddStockPortfolioState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createPortfolio,
          child: const Text('Create Portfolio'),
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
            Text('Add New Stock Portfolio',
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