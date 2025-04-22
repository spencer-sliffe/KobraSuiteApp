import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/grocery_list_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddGroceryListState { initial, adding, added }

class AddGroceryListBottomSheet extends StatefulWidget {
  const AddGroceryListBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddGroceryListBottomSheet> createState() =>
      _AddGroceryListBottomSheetState();
}

class _AddGroceryListBottomSheetState
    extends State<AddGroceryListBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _runDatetime;

  AddGroceryListState _state = AddGroceryListState.initial;
  String _error = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    /// Replace this body with your own custom picker if desired.
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _runDatetime ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate : now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_runDatetime ?? now),
    );
    if (time == null) return;
    setState(() {
      _runDatetime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddGroceryListState.adding;
      _error = '';
    });

    final ok = await context.read<GroceryListProvider>().createGroceryList(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      runDatetimeIso : _runDatetime!.toIso8601String(),
    );

    setState(() {
      _state = ok ? AddGroceryListState.added : AddGroceryListState.initial;
      if (!ok) _error = 'Failed to add grocery list.';
    });
  }

  // ------------------------------------------------------------ UI
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Grocery List',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // ---------- body ----------
            if (_state == AddGroceryListState.adding)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_state == AddGroceryListState.added)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Grocery list added.',
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
                        controller: _nameCtrl,
                        decoration:
                        const InputDecoration(labelText: 'List name'),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Description (optional)'),
                        maxLines: 2,
                      ),
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Grocery Run Date & time',
                            border : OutlineInputBorder(),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                _runDatetime == null
                                    ? 'Choose…'
                                    : MaterialLocalizations.of(context)
                                    .formatMediumDate(_runDatetime!) +
                                    '  ' +
                                    MaterialLocalizations.of(context)
                                        .formatTimeOfDay(TimeOfDay.fromDateTime(_runDatetime!)),
                              ),
                            ],
                          ),
                        ),
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
                if (_state != AddGroceryListState.adding)
                  TextButton(
                    onPressed: () => context
                        .read<NavigationStore>()
                        .setAddGroceryListActive(),
                    child: const Text('Cancel'),
                  ),
                if (_state == AddGroceryListState.initial)
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add List'),
                  ),
                if (_state == AddGroceryListState.added)
                  ElevatedButton(
                    onPressed: () => context
                        .read<NavigationStore>()
                        .setAddGroceryListActive(),
                    child: const Text('Close'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}