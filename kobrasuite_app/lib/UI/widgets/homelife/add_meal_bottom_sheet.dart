///Not SPECIFIED FOR MEAL JUST HAS BASIC EXAMPLE OF TEXT FIELDS
import 'package:flutter/material.dart';

enum AddMealState { initial, adding, added }

class AddMealBottomSheet extends StatefulWidget {
  const AddMealBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<AddMealBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddMealState _state = AddMealState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddMealState.adding;
      _errorFeedback = "";
    });

    // Simulate a service call. Replace with your actual API call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual call result.

    if (success) {
      setState(() {
        _state = AddMealState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add meal list.';
        _state = AddMealState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddMealState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding meal...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddMealState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Meal added successfully.',
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
              decoration: const InputDecoration(labelText: 'Meal Title'),
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
    if (_state == AddMealState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddMealState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMeal,
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
            Text('Add New Meal', style: Theme.of(context).textTheme.headlineSmall),
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