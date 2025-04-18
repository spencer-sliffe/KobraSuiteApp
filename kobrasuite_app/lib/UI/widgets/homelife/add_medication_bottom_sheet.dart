import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/medication_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum _SheetState { initial, adding, added }

class AddMedicationBottomSheet extends StatefulWidget {
  const AddMedicationBottomSheet({super.key});

  @override
  State<AddMedicationBottomSheet> createState() =>
      _AddMedicationBottomSheetState();
}

class _AddMedicationBottomSheetState extends State<AddMedicationBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl   = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl   = TextEditingController();
  final _notesCtrl  = TextEditingController();

  DateTime? _nextDose;                               // ← chosen value
  _SheetState _state = _SheetState.initial;
  String _error = '';

  Future<void> _pickNextDose() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _nextDose ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate : now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_nextDose ?? now),
    );
    if (time == null) return;
    setState(() {
      _nextDose =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = _SheetState.adding;
      _error = '';
    });

    final ok = await context.read<MedicationProvider>().createMedication(
      name       : _nameCtrl.text.trim(),
      dosage     : _dosageCtrl.text.trim(),
      frequency  : _freqCtrl.text.trim(),
      nextDoseIso: _nextDose?.toIso8601String(),
      notes      : _notesCtrl.text.trim(),
    );

    setState(() {
      _state = ok ? _SheetState.added : _SheetState.initial;
      if (!ok) {
        _error = context.read<MedicationProvider>().errorMessage ??
            'Failed to add medication.';
      }
    });
  }

  // ───────────────────── UI ─────────────────────
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
        child:
        Text('Medication added!', style: Theme.of(context).textTheme.titleLarge),
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
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickNextDose,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next dose (optional)',
                    border : OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        _nextDose == null
                            ? 'Choose…'
                            : MaterialLocalizations.of(context)
                            .formatMediumDate(_nextDose!) +
                            '  ' +
                            MaterialLocalizations.of(context)
                                .formatTimeOfDay(TimeOfDay.fromDateTime(_nextDose!)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration:
                const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
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
        onPressed: () =>
            context.read<NavigationStore>().setAddMedicationActive(),
        child: const Text('Close'),
      )
    ]
        : [
      TextButton(
        onPressed: () =>
            context.read<NavigationStore>().setAddMedicationActive(),
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
            Text('Add Medication',
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