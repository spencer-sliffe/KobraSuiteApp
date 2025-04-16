import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';

enum AddSharedCalendarEventState { initial, adding, added }

class AddSharedCalendarEventBottomSheet extends StatefulWidget {
  const AddSharedCalendarEventBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddSharedCalendarEventBottomSheet> createState() =>
      _AddSharedCalendarEventBottomSheetState();
}

class _AddSharedCalendarEventBottomSheetState
    extends State<AddSharedCalendarEventBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDatetimeController = TextEditingController();
  final TextEditingController _endDatetimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  AddSharedCalendarEventState _state = AddSharedCalendarEventState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _startDatetimeController.dispose();
    _endDatetimeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addCalendarEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddSharedCalendarEventState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual service call.

    if (success) {
      setState(() {
        _state = AddSharedCalendarEventState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add calendar event.';
        _state = AddSharedCalendarEventState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddSharedCalendarEventState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding calendar event...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddSharedCalendarEventState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Calendar event added successfully.',
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
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            // Start Datetime Field.
            TextFormField(
              controller: _startDatetimeController,
              decoration:
              const InputDecoration(labelText: 'Start Datetime (YYYY-MM-DD HH:MM)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter start datetime' : null,
            ),
            const SizedBox(height: 12),
            // End Datetime Field.
            TextFormField(
              controller: _endDatetimeController,
              decoration:
              const InputDecoration(labelText: 'End Datetime (YYYY-MM-DD HH:MM)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter end datetime' : null,
            ),
            const SizedBox(height: 12),
            // Description Field.
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // Location Field.
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter location' : null,
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
    if (_state == AddSharedCalendarEventState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddCalendarEventActive(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddSharedCalendarEventState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddCalendarEventActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addCalendarEvent,
          child: const Text('Add Event'),
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
            Text('Add New Calendar Event',
                style: Theme.of(context).textTheme.headlineSmall),
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