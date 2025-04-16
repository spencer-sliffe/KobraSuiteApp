import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';

enum AddGroceryListState { initial, adding, added }

class AddGroceryListBottomSheet extends StatefulWidget {
  const AddGroceryListBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddGroceryListBottomSheet> createState() => _AddGroceryListBottomSheetState();
}

class _AddGroceryListBottomSheetState extends State<AddGroceryListBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddGroceryListState _state = AddGroceryListState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addGroceryList() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddGroceryListState.adding;
      _errorFeedback = "";
    });

    // Simulate a service call. Replace with your actual API call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual call result.

    if (success) {
      setState(() {
        _state = AddGroceryListState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add grocery list.';
        _state = AddGroceryListState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddGroceryListState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding grocery list...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddGroceryListState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Grocery list added successfully.',
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
            // Title Field.
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Grocery List Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            // Description Field.
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
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
    if (_state == AddGroceryListState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddGroceryListActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddGroceryListState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddGroceryListActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addGroceryList,
          child: const Text('Add List'),
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
            Text('Add New Grocery List', style: Theme.of(context).textTheme.headlineSmall),
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