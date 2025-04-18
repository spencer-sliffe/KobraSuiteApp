import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/homelife/assignee.dart';
import '../../../providers/homelife/chore_provider.dart';
import '../../../providers/homelife/household_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddChoreState { initial, adding, added }

class AddChoreBottomSheet extends StatefulWidget {
  const AddChoreBottomSheet({super.key});

  @override
  State<AddChoreBottomSheet> createState() => _AddChoreBottomSheetState();
}

class _AddChoreBottomSheetState extends State<AddChoreBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _frequency;
  int _priority = 1;
  DateTime? _from;
  DateTime? _until;
  Assignee? _assignee;                       // ← keep the object itself

  AddChoreState _state = AddChoreState.initial;
  String _error = '';

  @override
  void initState() {
    super.initState();
    context.read<HouseholdProvider>().loadAssignees();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _from = picked;
        if (_until != null && _until!.isBefore(picked)) _until = null;
      } else {
        _until = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddChoreState.adding;
      _error = '';
    });

    final ok = await context.read<ChoreProvider>().createChore(
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      frequency: _frequency!,
      priority: _priority,
      availableFrom: _from?.toIso8601String(),
      availableUntil: _until?.toIso8601String(),
      assignedTo:     _assignee?.type == AssigneeType.adult ? _assignee!.id : null,
      childAssignedTo:_assignee?.type == AssigneeType.child ? _assignee!.id : null,
    );

    setState(() {
      _state = ok ? AddChoreState.added : AddChoreState.initial;
      if (!ok) _error = 'Failed to add chore.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignees = context.watch<HouseholdProvider>().assignees;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Chore',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // ---------- body ----------
            if (_state == AddChoreState.adding)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_state == AddChoreState.added)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Chore added.',
                    style: Theme.of(context).textTheme.titleLarge),
              )
            else
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration:
                        const InputDecoration(labelText: 'Chore title'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration:
                        const InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _frequency,
                        items: const ['ONE_TIME', 'DAILY', 'WEEKLY', 'MONTHLY']
                            .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f
                              .toLowerCase()
                              .replaceAll('_', ' ')
                              .toUpperCase()),
                        ))
                            .toList(),
                        decoration:
                        const InputDecoration(labelText: 'Frequency'),
                        onChanged: (v) => setState(() => _frequency = v),
                        validator: (v) =>
                        v == null ? 'Choose frequency' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _priority,
                        items: List.generate(
                            5,
                                (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            )),
                        decoration:
                        const InputDecoration(labelText: 'Priority'),
                        onChanged: (v) => setState(() => _priority = v ?? 1),
                      ),
                      const SizedBox(height: 12),
                      _dateField('Available from', true),
                      const SizedBox(height: 12),
                      _dateField('Available until', false),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Assignee>(
                        value: _assignee,
                        items: assignees
                            .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.name +
                              (a.type == AssigneeType.child
                                  ? ' (child)'
                                  : '')),
                        ))
                            .toList(),
                        decoration:
                        const InputDecoration(labelText: 'Assign to'),
                        onChanged: (v) => setState(() => _assignee = v),
                        validator: (v) => v == null ? 'Pick someone' : null,
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
              ),

            // ---------- actions ----------
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_state != AddChoreState.adding)
                  TextButton(
                    onPressed: () =>
                        context.read<NavigationStore>().setAddChoreActive(),
                    child: const Text('Cancel'),
                  ),
                if (_state == AddChoreState.initial)
                  ElevatedButton(onPressed: _submit, child: const Text('Add Chore')),
                if (_state == AddChoreState.added)
                  ElevatedButton(
                    onPressed: () =>
                        context.read<NavigationStore>().setAddChoreActive(),
                    child: const Text('Close'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // helper
  Widget _dateField(String label, bool isStart) {
    final dt = isStart ? _from : _until;
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _pickDate(isStart),
        ),
      ),
      controller: TextEditingController(
        text: dt == null ? '' : dt.toIso8601String().substring(0, 10),
      ),
    );
  }
}