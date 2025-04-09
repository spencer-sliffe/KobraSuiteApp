import 'package:flutter/material.dart';

enum AddAssignmentState { initial, adding, added }

class AddAssignmentBottomSheet extends StatefulWidget {
  const AddAssignmentBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddAssignmentBottomSheet> createState() => _AddAssignmentBottomSheetState();
}

class _AddAssignmentBottomSheetState extends State<AddAssignmentBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _courseIdController = TextEditingController();

  AddAssignmentState _state = AddAssignmentState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  Future<void> _addAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddAssignmentState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual service call result.

    if (success) {
      setState(() {
        _state = AddAssignmentState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add assignment.';
        _state = AddAssignmentState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddAssignmentState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding assignment...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddAssignmentState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Assignment added successfully.',
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
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Assignment Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            // Optional Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 12),
            // Due Date
            TextFormField(
              controller: _dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter due date' : null,
            ),
            const SizedBox(height: 12),
            // Course ID
            TextFormField(
              controller: _courseIdController,
              decoration: const InputDecoration(labelText: 'Course ID'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter course ID';
                }
                if (int.tryParse(value.trim()) == null) {
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddAssignmentState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddAssignmentState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addAssignment,
          child: const Text('Add Assignment'),
        )
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
            Text(
              'Add New Assignment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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