import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/homelife/grocery_list.dart';
import '../../../providers/homelife/grocery_item_provider.dart';
import '../../../providers/homelife/grocery_list_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum _UiState { idle, saving }

class AddGroceryItemBottomSheet extends StatefulWidget {
  const AddGroceryItemBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddGroceryItemBottomSheet> createState() =>
      _AddGroceryItemBottomSheetState();
}

class _AddGroceryItemBottomSheetState
    extends State<AddGroceryItemBottomSheet> {
  /* ---------- form controllers ---------- */
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  bool _purchased = false;

  /* ---------- state ---------- */
  int? _selectedListId;
  final List<_PendingItem> _pending = []; // queue
  String _error = '';
  _UiState _ui = _UiState.idle;

  @override
  void initState() {
    super.initState();
    context.read<GroceryListProvider>().loadGroceryLists();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  /* ---------- helpers ---------- */
  void _addToQueue() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _pending.add(
        _PendingItem(
          name: _nameCtrl.text.trim(),
          qty: _qtyCtrl.text.trim(),
          purchased: _purchased,
        ),
      );
      // clear mini‑form
      _nameCtrl.clear();
      _qtyCtrl.clear();
      _purchased = false;
    });
  }

  Future<void> _saveAll() async {
    if (_selectedListId == null) {
      setState(() => _error = 'Choose a grocery list first');
      return;
    }
    if (_pending.isEmpty) {
      setState(() => _error = 'Add at least one item');
      return;
    }

    setState(() {
      _ui = _UiState.saving;
      _error = '';
    });

    final provider = context.read<GroceryItemProvider>();
    bool overallOk = true;

    // save sequentially – easier for progress / error handling
    for (final item in _pending) {
      final ok = await provider.createGroceryItem(
        groceryListId: _selectedListId!,
        name: item.name,
        quantity: item.qty.isEmpty ? null : item.qty,
        purchased: item.purchased,
      );
      if (!ok) overallOk = false;
    }

    if (overallOk) {
      // clear queue + close sheet
      if (mounted) {
        context.read<NavigationStore>().setAddGroceryItemActive();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${_pending.length} item(s).')),
        );
      }
    } else {
      setState(() {
        _ui = _UiState.idle;
        _error = 'Some items failed to save – please try again.';
      });
    }
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    final lists = context.watch<GroceryListProvider>().groceryLists;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Grocery Items',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // list selector (outside mini‑form so it’s chosen once)
            DropdownButtonFormField<int>(
              value: _selectedListId,
              items: lists
                  .map((GroceryList l) => DropdownMenuItem<int>(
                value: l.id,
                child: Text(l.name),
              ))
                  .toList(),
              decoration:
              const InputDecoration(labelText: 'Grocery list to add to'),
              onChanged: _ui == _UiState.saving
                  ? null
                  : (v) => setState(() => _selectedListId = v),
              validator: (v) =>
              v == null ? 'Select a grocery list' : null,
            ),
            const SizedBox(height: 16),

            // ------------- mini‑form -------------
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Item name'),
                    enabled: _ui == _UiState.idle,
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _qtyCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Quantity'),
                    enabled: _ui == _UiState.idle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Purchased'),
                      Switch(
                        value: _purchased,
                        onChanged: _ui == _UiState.idle
                            ? (v) => setState(() => _purchased = v)
                            : null,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Queue item'),
                        onPressed: _ui == _UiState.idle ? _addToQueue : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ------------- pending chips -------------
            if (_pending.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: _pending
                    .asMap()
                    .entries
                    .map(
                      (e) => Chip(
                    label: Text(e.value.name),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: _ui == _UiState.idle
                        ? () => setState(() => _pending.removeAt(e.key))
                        : null,
                  ),
                )
                    .toList(),
              ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _ui == _UiState.saving
                      ? null
                      : () => context
                      .read<NavigationStore>()
                      .setAddGroceryItemActive(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                (_ui == _UiState.saving)
                    ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                      'Save ${_pending.length} item${_pending.length == 1 ? '' : 's'}'),
                  onPressed:
                  _pending.isEmpty ? null : () => _saveAll(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- local helper class ---------- */
class _PendingItem {
  final String name;
  final String qty;
  final bool purchased;
  _PendingItem({
    required this.name,
    required this.qty,
    required this.purchased,
  });
}