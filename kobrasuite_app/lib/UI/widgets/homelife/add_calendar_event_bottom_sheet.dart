import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/homelife/calendar_provider.dart';
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

  Future<void> _selectDateTime({required bool isStart}) async {
    final now = DateTime.now();
    DateTime initial = now;
    final existingText = isStart
        ? _startDatetimeController.text
        : _endDatetimeController.text;
    if (existingText.isNotEmpty) {
      try {
        initial = DateFormat('yyyy-MM-dd HH:mm').parseStrict(existingText);
      } catch (_) {}
    }
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(picked);
    setState(() {
      if (isStart) {
        _startDatetimeController.text = formatted;
      } else {
        _endDatetimeController.text = formatted;
      }
    });
  }

  Future<void> _addCalendarEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddSharedCalendarEventState.adding;
      _errorFeedback = "";
    });
    final calendarProvider = context.read<CalendarProvider>();
    final success = await calendarProvider.createCalendarEvent(
      title: _titleController.text.trim(),
      startDateTime: _startDatetimeController.text.trim(),
      endDateTime: _endDatetimeController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );
    if (success) {
      setState(() => _state = AddSharedCalendarEventState.added);
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startDatetimeController,
              decoration: const InputDecoration(
                labelText: 'Start Datetime',
                hintText: 'YYYY-MM-DD HH:MM',
              ),
              readOnly: true,
              onTap: () => _selectDateTime(isStart: true),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter start datetime'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _endDatetimeController,
              decoration: const InputDecoration(
                labelText: 'End Datetime',
                hintText: 'YYYY-MM-DD HH:MM',
              ),
              readOnly: true,
              onTap: () => _selectDateTime(isStart: false),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter end datetime' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter location' : null,
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
          onPressed: () =>
              context.read<NavigationStore>().setAddCalendarEventActive(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddSharedCalendarEventState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddCalendarEventActive(),
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
            Text(
              'Add New Calendar Event',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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