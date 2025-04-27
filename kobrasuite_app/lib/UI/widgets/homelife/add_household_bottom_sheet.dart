import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/homelife/household_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum _Mode { create, join }
enum _State { idle, working, done }

class AddHouseholdBottomSheet extends StatefulWidget {
  const AddHouseholdBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddHouseholdBottomSheet> createState() =>
      _AddHouseholdBottomSheetState();
}

class _AddHouseholdBottomSheetState extends State<AddHouseholdBottomSheet> {
  final _form = GlobalKey<FormState>();

  final _nameCtrl   = TextEditingController();
  final _codeCtrl   = TextEditingController();

  String _type      = 'FAMILY';
  _Mode   _mode     = _Mode.create;
  _State  _state    = _State.idle;
  String  _error    = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // --------------------- actions ---------------------------------

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _state = _State.working; _error = ''; });

    final householdProv = context.read<HouseholdProvider>();

    bool ok = false;

    if (_mode == _Mode.create) {
      // 1. create household
      ok = await householdProv.createHousehold(
        householdName: _nameCtrl.text.trim(),
        householdType: _type,
      );

      // 2. grab the freshly-created id
      final hhId = householdProv.household?.id;

      // 3. create invite with that id
      if (ok && hhId != null) {
        ok = await inviteProv.create(
          householdPk: hhId,
          code: _codeCtrl.text.trim(),
        );
      } else {
        ok = false;
      }
    } else {
      // join
      ok = await inviteProv.redeem(_codeCtrl.text.trim());
      if (ok) await householdProv.loadHousehold();
    }

    setState(() => _state = ok ? _State.done : _State.idle);
    if (!ok) {
      _error = inviteProv.errorMsg ??
          householdProv.errorMessage ??
          'Operation failed';
    }
  }

  // --------------------- UI helpers ------------------------------

  InputDecoration _dec(String label) => InputDecoration(labelText: label);

  Widget _modeSelector() => SegmentedButton<_Mode>(
    segments: const [
      ButtonSegment(value: _Mode.create, label: Text('Create')),
      ButtonSegment(value: _Mode.join,   label: Text('Join')),
    ],
    selected: {_mode},
    onSelectionChanged: (s) => setState(() => _mode = s.first),
  );

  List<Widget> _buildFormFields() {
    if (_mode == _Mode.create) {
      return [
        TextFormField(
          controller: _nameCtrl,
          decoration: _dec('Household name'),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _type,
          decoration: _dec('Household type'),
          items: const [
            DropdownMenuItem(value: 'FAMILY',    child: Text('Family')),
            DropdownMenuItem(value: 'ROOMMATES', child: Text('Roommates')),
            DropdownMenuItem(value: 'COUPLE',    child: Text('Couple')),
          ],
          onChanged: (v) => setState(() => _type = v ?? 'FAMILY'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _codeCtrl,
          decoration: _dec('Invite code (shareable)'),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ];
    }
    // join
    return [
      TextFormField(
        controller: _codeCtrl,
        decoration: _dec('Household invite code'),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    ];
  }

  // --------------------- build -----------------------------------

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationStore>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Join or Create a Household',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _modeSelector(),
            const SizedBox(height: 16),

            if (_state == _State.working)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_state == _State.done)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Icon(Icons.check_circle, size: 48),
              )
            else
              Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildFormFields(),
                ),
              ),

            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error,
                    style: TextStyle(color: Colors.red.shade700)),
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: nav.setAddHouseholdActive,
                  child: const Text('Close'),
                ),
                if (_state == _State.idle)
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_mode == _Mode.create ? 'Create' : 'Join'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}