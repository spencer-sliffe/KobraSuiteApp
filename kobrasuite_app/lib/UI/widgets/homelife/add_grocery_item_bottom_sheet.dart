import 'package:flutter/material.dart';

enum AddGroceryItemState { initial, adding, added }

class AddGroceryItemBottomSheet extends StatefulWidget {
  const AddGroceryItemBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddGroceryItemBottomSheet> createState() =>
      _AddGroceryItemBottomSheetState();
}

class _AddGroceryItemBottomSheetState extends State<AddGroceryItemBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Use a bool for purchased – default is false.
  bool _purchased = false;

  AddGroceryItemState _state = AddGroceryItemState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addGroceryItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddGroceryItemState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your API/service call.

    if (success) {
      setState(() {
        _state = AddGroceryItemState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add grocery item.';
        _state = AddGroceryItemState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddGroceryItemState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding grocery item...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddGroceryItemState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Grocery item added successfully.',
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
            // Item Name.
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter item name' : null,
            ),
            const SizedBox(height: 12),
            // Quantity.
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              // Quantity can be optional. If desired, add validation here.
            ),
            const SizedBox(height: 12),
            // Purchased toggle.
            Row(
              children: [
                const Text('Purchased:'),
                Switch(
                  value: _purchased,
                  onChanged: (value) {
                    setState(() {
                      _purchased = value;
                    });
                  },
                ),
              ],
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddGroceryItemState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddGroceryItemState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addGroceryItem,
          child: const Text('Add Item'),
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
            Text('Add New Grocery Item', style: Theme.of(context).textTheme.headlineSmall),
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