import 'package:flutter/material.dart';

enum AddMedicalAppointmentState { initial, adding, added }

class AddMedicalAppointmentBottomSheet extends StatefulWidget {
  const AddMedicalAppointmentBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddMedicalAppointmentBottomSheet> createState() =>
      _AddMedicalAppointmentBottomSheetState();
}

class _AddMedicalAppointmentBottomSheetState
    extends State<AddMedicalAppointmentBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for appointment fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _appointmentDatetimeController =
  TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddMedicalAppointmentState _state = AddMedicalAppointmentState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _appointmentDatetimeController.dispose();
    _doctorNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addMedicalAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddMedicalAppointmentState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual API/service call result.

    if (success) {
      setState(() {
        _state = AddMedicalAppointmentState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add medical appointment.';
        _state = AddMedicalAppointmentState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddMedicalAppointmentState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding appointment...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddMedicalAppointmentState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Medical appointment added successfully.',
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
              decoration: const InputDecoration(labelText: 'Appointment Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            // Appointment Datetime Field.
            TextFormField(
              controller: _appointmentDatetimeController,
              decoration: const InputDecoration(
                  labelText: 'Appointment Datetime (YYYY-MM-DD HH:MM)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter appointment datetime' : null,
            ),
            const SizedBox(height: 12),
            // Doctor Name (optional).
            TextFormField(
              controller: _doctorNameController,
              decoration: const InputDecoration(labelText: 'Doctor Name (optional)'),
            ),
            const SizedBox(height: 12),
            // Location Field.
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter location' : null,
            ),
            const SizedBox(height: 12),
            // Description Field.
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
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
    if (_state == AddMedicalAppointmentState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddMedicalAppointmentState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMedicalAppointment,
          child: const Text('Add Appointment'),
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
            Text('Add New Medical Appointment',
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