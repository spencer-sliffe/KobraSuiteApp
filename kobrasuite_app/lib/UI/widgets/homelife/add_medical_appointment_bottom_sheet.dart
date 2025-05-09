import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/medical_appointment_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum _SheetState { initial, adding, added }

class AddMedicalAppointmentBottomSheet extends StatefulWidget {
  const AddMedicalAppointmentBottomSheet({super.key});

  @override
  State<AddMedicalAppointmentBottomSheet> createState() =>
      _AddMedicalAppointmentBottomSheetState();
}

class _AddMedicalAppointmentBottomSheetState
    extends State<AddMedicalAppointmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl       = TextEditingController();
  final _doctorCtrl      = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  DateTime? _when;                                 // ← chosen value
  _SheetState _state = _SheetState.initial;
  String _error = '';

  // ───────────────────────── helpers ──────────────────────────
  Future<void> _pickDateTime() async {
    /// Replace this body with your own custom picker if desired.
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate : now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when ?? now),
    );
    if (time == null) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_when == null) {
      setState(() => _error = 'Pick a date & time');
      return;
    }

    setState(() {
      _state = _SheetState.adding;
      _error = '';
    });

    final ok = await context.read<MedicalAppointmentProvider>()
        .createMedicalAppointment(
      title          : _titleCtrl.text.trim(),
      appointmentIso : _when!.toIso8601String(),
      doctorName     : _doctorCtrl.text.trim(),
      location       : _locationCtrl.text.trim(),
      description    : _descriptionCtrl.text.trim(),
    );

    setState(() {
      _state = ok ? _SheetState.added : _SheetState.initial;
      if (!ok) {
        _error = context.read<MedicalAppointmentProvider>().errorMessage ??
            'Failed to add appointment.';
      }
    });
  }

  // ───────────────────────── UI ──────────────────────────
  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_state == _SheetState.adding) {
      body = const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    } else if (_state == _SheetState.added) {
      body = Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Appointment added!',
            style: Theme.of(context).textTheme.titleLarge),
      );
    } else {
      body = Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // ── Date‑time chip ────────────────────────────
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date & time',
                    border : OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        _when == null
                            ? 'Choose…'
                            : MaterialLocalizations.of(context)
                            .formatMediumDate(_when!) +
                            '  ' +
                            MaterialLocalizations.of(context)
                                .formatTimeOfDay(TimeOfDay.fromDateTime(_when!)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorCtrl,
                decoration:
                const InputDecoration(labelText: 'Doctor (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      );
    }

    final actions = (_state == _SheetState.added)
        ? [
      TextButton(
        onPressed: () => context
            .read<NavigationStore>()
            .setAddMedicalAppointmentActive(),
        child: const Text('Close'),
      )
    ]
        : [
      TextButton(
        onPressed: () => context
            .read<NavigationStore>()
            .setAddMedicalAppointmentActive(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(onPressed: _submit, child: const Text('Add')),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Medical Appointment',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            body,
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ],
        ),
      ),
    );
  }
}