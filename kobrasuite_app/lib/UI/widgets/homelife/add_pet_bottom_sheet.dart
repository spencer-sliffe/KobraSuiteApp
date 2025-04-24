import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/homelife/pet_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddPetState { initial, adding, added }

class AddPetBottomSheet extends StatefulWidget {
  const AddPetBottomSheet({super.key});

  @override
  State<AddPetBottomSheet> createState() => _AddPetBottomSheetState();
}

class _AddPetBottomSheetState extends State<AddPetBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  /* ── basic ────────────────────────────────────────── */
  final _nameCtl = TextEditingController();
  final _typeCtl = TextEditingController();

  /* ── optional care blocks ─────────────────────────── */
  // food
  bool _showFood = false;
  final _foodInstrCtl = TextEditingController();
  String? _foodFreq;
  final List<TimeOfDay> _foodTimes = [];

  // water
  bool _showWater = false;
  final _waterInstrCtl = TextEditingController();
  String? _waterFreq;
  final List<TimeOfDay> _waterTimes = [];

  // medication
  bool _showMed = false;
  final _medInstrCtl = TextEditingController();
  String? _medFreq;
  final List<TimeOfDay> _medTimes = [];

  static const _freqOpts = ['ONCE', 'DAILY', 'WEEKLY'];

  AddPetState _state = AddPetState.initial;
  String _error = '';

  /* ── helpers ───────────────────────────────────────── */
  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickAndAddTime(List<TimeOfDay> bucket, String freq) async {
    if (freq != 'DAILY' && bucket.isNotEmpty) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null && !bucket.contains(t)) {
      setState(() => bucket.add(t));
    }
  }

  Widget _freqDropdown(String? value, void Function(String?) onChanged, String label) =>
      DropdownButtonFormField<String>(
        value: value,
        items: _freqOpts
            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
            .toList(),
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        validator: (v) =>
        (_isActive(label) && v == null) ? 'Choose $label' : null,
      );

  bool _isActive(String label) =>
      (label.startsWith('Food') && _showFood) ||
          (label.startsWith('Water') && _showWater) ||
          (label.startsWith('Medication') && _showMed);

  Widget _timeChips(List<TimeOfDay> times, void Function(int) onDel) => Wrap(
    spacing: 4,
    children: [
      for (var i = 0; i < times.length; i++)
        Chip(
          label: Text(times[i].format(context)),
          onDeleted: () => setState(() => onDel(i)),
        )
    ],
  );

  /* ── submit ────────────────────────────────────────── */
  bool _validBlock(bool show, String? freq, List<TimeOfDay> times) {
    if (!show) return true; // optional
    if (freq == null || times.isEmpty) return false;
    if (freq != 'DAILY' && times.length != 1) return false;
    return true;
  }

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final okBlocks = _validBlock(_showFood, _foodFreq, _foodTimes) &&
        _validBlock(_showWater, _waterFreq, _waterTimes) &&
        _validBlock(_showMed, _medFreq, _medTimes);

    if (!okBlocks) {
      setState(() => _error =
      'Each active section needs a frequency and at least one valid time.');
      return;
    }

    setState(() {
      _state = AddPetState.adding;
      _error = '';
    });

    final provider = context.read<PetProvider>();
    final ok = await provider.createPet(
      petName: _nameCtl.text.trim(),
      petType: _typeCtl.text.trim(),
      foodInstructions: _showFood ? _foodInstrCtl.text.trim() : '',
      waterInstructions: _showWater ? _waterInstrCtl.text.trim() : '',
      medicationInstructions: _showMed ? _medInstrCtl.text.trim() : '',
      foodFrequency: _showFood ? _foodFreq! : '',
      waterFrequency: _showWater ? _waterFreq! : '',
      medicationFrequency: _showMed ? _medFreq! : '',
      foodTimes: _showFood ? _foodTimes.map(_fmt).toList() : null,
      waterTimes: _showWater ? _waterTimes.map(_fmt).toList() : null,
      medicationTimes: _showMed ? _medTimes.map(_fmt).toList() : null,
    );

    setState(() {
      _state = ok ? AddPetState.added : AddPetState.initial;
      if (!ok) _error = 'Failed to add pet.';
    });
  }

  /* ── UI pieces ─────────────────────────────────────── */
  Widget _addChip(String label, VoidCallback onTap) => ActionChip(
    avatar: const Icon(Icons.add),
    label: Text(label),
    onPressed: onTap,
  );

  Widget _careBlock({
    required bool show,
    required VoidCallback onRemove,
    required TextEditingController instr,
    required String? freq,
    required void Function(String?) onFreqChanged,
    required List<TimeOfDay> times,
    required String label,
  }) {
    if (!show) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label Care', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
          ],
        ),
        TextFormField(
          controller: instr,
          maxLines: 2,
          decoration: InputDecoration(labelText: '$label Instructions'),
        ),
        const SizedBox(height: 8),
        _freqDropdown(freq, onFreqChanged, '$label Frequency'),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Times', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: (freq == null) ? null : () => _pickAndAddTime(times, freq),
            ),
          ],
        ),
        _timeChips(times, (i) => times.removeAt(i)),
        const SizedBox(height: 16),
      ],
    );
  }

  /* ── form ──────────────────────────────────────────── */
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // basic
          TextFormField(
            controller: _nameCtl,
            decoration: const InputDecoration(labelText: 'Pet Name *'),
            validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter pet name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _typeCtl,
            decoration: const InputDecoration(labelText: 'Pet Type *'),
            validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter pet type' : null,
          ),
          const SizedBox(height: 24),

          // optional care sections
          if (!_showFood || !_showWater || !_showMed)
            Wrap(
              spacing: 8,
              children: [
                if (!_showFood)
                  _addChip('Add Food', () => setState(() => _showFood = true)),
                if (!_showWater)
                  _addChip('Add Water', () => setState(() => _showWater = true)),
                if (!_showMed)
                  _addChip('Add Medication',
                          () => setState(() => _showMed = true)),
              ],
            ),
          const SizedBox(height: 16),
          _careBlock(
              show: _showFood,
              onRemove: () => setState(() {
                _showFood = false;
                _foodFreq = null;
                _foodTimes.clear();
                _foodInstrCtl.clear();
              }),
              instr: _foodInstrCtl,
              freq: _foodFreq,
              onFreqChanged: (v) => setState(() {
                _foodFreq = v;
                _foodTimes.clear();
              }),
              times: _foodTimes,
              label: 'Food'),
          _careBlock(
              show: _showWater,
              onRemove: () => setState(() {
                _showWater = false;
                _waterFreq = null;
                _waterTimes.clear();
                _waterInstrCtl.clear();
              }),
              instr: _waterInstrCtl,
              freq: _waterFreq,
              onFreqChanged: (v) => setState(() {
                _waterFreq = v;
                _waterTimes.clear();
              }),
              times: _waterTimes,
              label: 'Water'),
          _careBlock(
              show: _showMed,
              onRemove: () => setState(() {
                _showMed = false;
                _medFreq = null;
                _medTimes.clear();
                _medInstrCtl.clear();
              }),
              instr: _medInstrCtl,
              freq: _medFreq,
              onFreqChanged: (v) => setState(() {
                _medFreq = v;
                _medTimes.clear();
              }),
              times: _medTimes,
              label: 'Medication'),

          if (_error.isNotEmpty)
            Text(_error,
                style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
        ],
      ),
    );
  }

  /* ── build ─────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_state == AddPetState.adding) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_state == AddPetState.added) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text('Pet added!',
              style: Theme.of(context).textTheme.titleLarge),
        ),
      );
    } else {
      content = _buildForm();
    }

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Pet',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_state == AddPetState.added)
                    TextButton(
                        onPressed: () => context
                            .read<NavigationStore>()
                            .setAddPetActive(),
                        child: const Text('Close')),
                  if (_state == AddPetState.initial) ...[
                    TextButton(
                        onPressed: () => context
                            .read<NavigationStore>()
                            .setAddPetActive(),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: _addPet, child: const Text('Add Pet')),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}