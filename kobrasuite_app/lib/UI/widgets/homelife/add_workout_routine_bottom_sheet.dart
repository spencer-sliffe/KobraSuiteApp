import 'package:flutter/material.dart';

enum AddWorkoutRoutineState { initial, adding, added }

class AddWorkoutRoutineBottomSheet extends StatefulWidget {
  const AddWorkoutRoutineBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddWorkoutRoutineBottomSheet> createState() =>
      _AddWorkoutRoutineBottomSheetState();
}

class _AddWorkoutRoutineBottomSheetState extends State<AddWorkoutRoutineBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _exercisesController = TextEditingController();

  AddWorkoutRoutineState _state = AddWorkoutRoutineState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    _exercisesController.dispose();
    super.dispose();
  }

  Future<void> _addWorkoutRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddWorkoutRoutineState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual API call.

    if (success) {
      setState(() {
        _state = AddWorkoutRoutineState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add workout routine.';
        _state = AddWorkoutRoutineState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddWorkoutRoutineState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding workout routine...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddWorkoutRoutineState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Workout routine added successfully.',
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
              decoration: const InputDecoration(labelText: 'Routine Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            // Description Field (optional).
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Schedule Field.
            TextFormField(
              controller: _scheduleController,
              decoration: const InputDecoration(labelText: 'Schedule (e.g., Mon, Wed, Fri)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter schedule' : null,
            ),
            const SizedBox(height: 12),
            // Exercises Field.
            TextFormField(
              controller: _exercisesController,
              decoration: const InputDecoration(labelText: 'Exercises (comma-separated)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter exercises' : null,
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
    if (_state == AddWorkoutRoutineState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddWorkoutRoutineState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addWorkoutRoutine,
          child: const Text('Add Routine'),
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
            Text('Add New Workout Routine',
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