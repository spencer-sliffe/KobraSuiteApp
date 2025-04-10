import 'package:flutter/material.dart';

enum AddChoreState { initial, adding, added }

class AddChoreBottomSheet extends StatefulWidget {
  const AddChoreBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddChoreBottomSheet> createState() => _AddChoreBottomSheetState();
}

class _AddChoreBottomSheetState extends State<AddChoreBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for chore fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _availableFromController = TextEditingController();
  final TextEditingController _availableUntilController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();

  AddChoreState _state = AddChoreState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _priorityController.dispose();
    _availableFromController.dispose();
    _availableUntilController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _addChore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddChoreState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your API call result.

    if (success) {
      setState(() {
        _state = AddChoreState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add chore.';
        _state = AddChoreState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddChoreState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding chore...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddChoreState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Chore added successfully.',
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
            // Title (required)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Chore Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter chore title' : null,
            ),
            const SizedBox(height: 12),
            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Frequency (required)
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency (e.g., Daily, Weekly)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter frequency' : null,
            ),
            const SizedBox(height: 12),
            // Priority (required, numeric)
            TextFormField(
              controller: _priorityController,
              decoration: const InputDecoration(labelText: 'Priority (1-5)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter priority';
                final intVal = int.tryParse(value.trim());
                if (intVal == null || intVal < 1 || intVal > 5) return 'Enter a value between 1 and 5';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Available From (optional)
            TextFormField(
              controller: _availableFromController,
              decoration: const InputDecoration(labelText: 'Available From (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            // Available Until (optional)
            TextFormField(
              controller: _availableUntilController,
              decoration: const InputDecoration(labelText: 'Available Until (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            // Assigned To (optional, numeric)
            TextFormField(
              controller: _assignedToController,
              decoration: const InputDecoration(labelText: 'Assigned To (Profile ID)'),
              keyboardType: TextInputType.number,
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
    if (_state == AddChoreState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddChoreState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addChore,
          child: const Text('Add Chore'),
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
            Text('Add New Chore', style: Theme.of(context).textTheme.headlineSmall),
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