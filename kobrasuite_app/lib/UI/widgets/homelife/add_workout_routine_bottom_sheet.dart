import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/workout_routine_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddWorkoutRoutineState { initial, adding, added }

class AddWorkoutRoutineBottomSheet extends StatefulWidget {
  const AddWorkoutRoutineBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddWorkoutRoutineBottomSheet> createState() =>
      _AddWorkoutRoutineBottomSheetState();
}

class _AddWorkoutRoutineBottomSheetState
    extends State<AddWorkoutRoutineBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddWorkoutRoutineState _state = AddWorkoutRoutineState.initial;
  String _errorFeedback = "";

  static const _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  final List<bool> _selectedDays = List<bool>.filled(_days.length, false);

  // --- Exercises state ---
  final List<TextEditingController> _exerciseControllers = [];

  @override
  void initState() {
    super.initState();
    _addExerciseField();
  }

  void _addExerciseField() {
    setState(() {
      _exerciseControllers.add(TextEditingController());
    });
  }

  void _removeExerciseField(int index) {
    setState(() {
      _exerciseControllers[index].dispose();
      _exerciseControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _exerciseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addWorkoutRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDaysList = <String>[];
    for (var i = 0; i < _days.length; i++) {
      if (_selectedDays[i]) selectedDaysList.add(_days[i]);
    }
    if (selectedDaysList.isEmpty) {
      setState(() => _errorFeedback = 'Please select at least one day.');
      return;
    }

    final exercises = _exerciseControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (exercises.isEmpty) {
      setState(() => _errorFeedback = 'Please add at least one exercise.');
      return;
    }

    setState(() {
      _state = AddWorkoutRoutineState.adding;
      _errorFeedback = "";
    });

    final workoutRoutineProvider = context.read<WorkoutRoutineProvider>();
    final success = await workoutRoutineProvider.createWorkoutRoutine(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      schedule: selectedDaysList,
      exercises: exercises.join(', '),
    );

    if (success) {
      setState(() => _state = AddWorkoutRoutineState.added);
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Routine Title'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration:
              const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Schedule toggles
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Schedule', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: _selectedDays,
              onPressed: (i) {
                setState(() => _selectedDays[i] = !_selectedDays[i]);
              },
              children: _days.map((d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(d),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Exercises list
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Exercises', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            ..._exerciseControllers.asMap().entries.map((e) {
              final idx = e.key;
              final ctrl = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          labelText: 'Exercise ${idx + 1}',
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Enter exercise'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_exerciseControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeExerciseField(idx),
                      ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addExerciseField,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
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
          onPressed: () =>
              context.read<NavigationStore>().setAddWorkoutRoutineActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddWorkoutRoutineState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddWorkoutRoutineActive(),
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