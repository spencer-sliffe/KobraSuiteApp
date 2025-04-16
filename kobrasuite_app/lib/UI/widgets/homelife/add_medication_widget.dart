import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';

enum AddMedicationState { initial, adding, added }

class AddMedicationBottomSheet extends StatefulWidget {
  const AddMedicationBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddMedicationBottomSheet> createState() => _AddMedicationBottomSheetState();
}

class _AddMedicationBottomSheetState extends State<AddMedicationBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for medication fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _nextDoseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  AddMedicationState _state = AddMedicationState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _nextDoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddMedicationState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual API/service call.

    if (success) {
      setState(() {
        _state = AddMedicationState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add medication.';
        _state = AddMedicationState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddMedicationState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding medication...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddMedicationState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Medication added successfully.',
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
            // Name Field.
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            // Dosage Field.
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter dosage' : null,
            ),
            const SizedBox(height: 12),
            // Frequency Field.
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: 'Frequency'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter frequency' : null,
            ),
            const SizedBox(height: 12),
            // Next Dose Field (optional).
            TextFormField(
              controller: _nextDoseController,
              decoration:
              const InputDecoration(labelText: 'Next Dose (YYYY-MM-DD HH:MM, optional)'),
            ),
            const SizedBox(height: 12),
            // Notes Field (optional).
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
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
    if (_state == AddMedicationState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddMedicationActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddMedicationState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddMedicationActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMedication,
          child: const Text('Add Medication'),
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
            Text('Add New Medication',
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