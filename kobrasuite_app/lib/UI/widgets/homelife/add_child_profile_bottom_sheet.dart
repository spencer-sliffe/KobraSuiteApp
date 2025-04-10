import 'package:flutter/material.dart';

enum AddChildProfileState { initial, adding, added }

class AddChildProfileBottomSheet extends StatefulWidget {
  const AddChildProfileBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddChildProfileBottomSheet> createState() => _AddChildProfileBottomSheetState();
}

class _AddChildProfileBottomSheetState extends State<AddChildProfileBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the fields.
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  AddChildProfileState _state = AddChildProfileState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _childNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _addChildProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddChildProfileState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous API/service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your real call.

    if (success) {
      setState(() {
        _state = AddChildProfileState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add child profile.';
        _state = AddChildProfileState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddChildProfileState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding child profile...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddChildProfileState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Child profile added successfully.',
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
            // Child Name
            TextFormField(
              controller: _childNameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter child name' : null,
            ),
            const SizedBox(height: 12),
            // Date of Birth (optional)
            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
              // Optionally add a validator if needed.
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
    if (_state == AddChildProfileState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddChildProfileState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addChildProfile,
          child: const Text('Add Child'),
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
            Text('Add New Child Profile', style: Theme.of(context).textTheme.headlineSmall),
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