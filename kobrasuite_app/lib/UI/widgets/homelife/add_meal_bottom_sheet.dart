import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/meal_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddMealState { initial, adding, added }

class AddMealBottomSheet extends StatefulWidget {
  const AddMealBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<AddMealBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _date;
  String? _mealType;
  final _recipeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  AddMealState _state = AddMealState.initial;
  String _error = '';

  final _mealTypes = const ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];

  @override
  void dispose() {
    _recipeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddMealState.adding;
      _error = '';
    });

    final ok = await context.read<MealProvider>().createMeal(
      date: _date!.toIso8601String().substring(0, 10),
      mealType: _mealType!,
      recipeName: _recipeCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    setState(() {
      _state = ok ? AddMealState.added : AddMealState.initial;
      if (!ok) _error = 'Failed to add meal.';
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
            Text('Add New Meal',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            if (_state == AddMealState.adding)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_state == AddMealState.added)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Meal added.',
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
                      // --- date ---
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDate,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _date == null
                              ? ''
                              : _date!.toIso8601String().substring(0, 10),
                        ),
                        validator: (v) =>
                        _date == null ? 'Pick a date' : null,
                      ),
                      const SizedBox(height: 12),

                      // --- meal type ---
                      DropdownButtonFormField<String>(
                        value: _mealType,
                        items: _mealTypes
                            .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ))
                            .toList(),
                        decoration:
                        const InputDecoration(labelText: 'Meal type'),
                        onChanged: (v) => setState(() => _mealType = v),
                        validator: (v) =>
                        v == null ? 'Choose meal type' : null,
                      ),
                      const SizedBox(height: 12),

                      // --- recipe name ---
                      TextFormField(
                        controller: _recipeCtrl,
                        decoration:
                        const InputDecoration(labelText: 'Recipe name'),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // --- notes ---
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
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
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_state != AddMealState.adding)
                  TextButton(
                    onPressed: () =>
                        context.read<NavigationStore>().setAddMealActive(),
                    child: const Text('Cancel'),
                  ),
                if (_state == AddMealState.initial)
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Meal'),
                  ),
                if (_state == AddMealState.added)
                  ElevatedButton(
                    onPressed: () =>
                        context.read<NavigationStore>().setAddMealActive(),
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