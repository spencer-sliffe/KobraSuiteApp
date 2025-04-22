import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/homelife/pet_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddPetState { initial, adding, added }

class AddPetBottomSheet extends StatefulWidget {
  const AddPetBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddPetBottomSheet> createState() => _AddPetBottomSheetState();
}

class _AddPetBottomSheetState extends State<AddPetBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for pet fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _petTypeController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _foodInstructionsController = TextEditingController();
  final TextEditingController _waterInstructionsController = TextEditingController();
  String? _frequencyType;

  AddPetState _state = AddPetState.initial;
  String _errorFeedback = "";
  final _frequencyTypes = const ['MORNINGANDNIGHT', 'ONCE', 'DAILY', 'WEEKLY'];


  @override
  void dispose() {
    _nameController.dispose();
    _petTypeController.dispose();
    _specialInstructionsController.dispose();
    _medicationsController.dispose();
    _foodInstructionsController.dispose();
    _waterInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddPetState.adding;
      _errorFeedback = "";
    });
    final petProvider = context.read<PetProvider>();
    final success = await petProvider.createPet(
      petName: _nameController.text.trim(),
      petType: _petTypeController.text.trim(),
      specialInstructions: _specialInstructionsController.text.trim(),
      medications: _medicationsController.text.trim(),
      foodInstructions: _foodInstructionsController.text.trim(),
      waterInstructions: _waterInstructionsController.text.trim(),
      careFrequency: _frequencyType!,
    );

    if (success) {
      setState(() {
        _state = AddPetState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add pet.';
        _state = AddPetState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddPetState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding pet...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddPetState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Pet added successfully.',
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
            // Pet Name (required)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Pet Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter pet name' : null,
            ),
            const SizedBox(height: 12),
            // Pet Type (required)
            TextFormField(
              controller: _petTypeController,
              decoration: const InputDecoration(labelText: 'Pet Type'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter pet type' : null,
            ),
            const SizedBox(height: 12),
            // Special Instructions (optional)
            TextFormField(
              controller: _specialInstructionsController,
              decoration: const InputDecoration(labelText: 'Special Instructions'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Medications (optional)
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(labelText: 'Medications'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Food Instructions (optional)
            TextFormField(
              controller: _foodInstructionsController,
              decoration: const InputDecoration(labelText: 'Food Instructions'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Water Instructions (optional)
            TextFormField(
              controller: _waterInstructionsController,
              decoration: const InputDecoration(labelText: 'Water Instructions'),
              maxLines: 2,
            ),
            DropdownButtonFormField<String>(
              value: _frequencyType,
              items: _frequencyTypes
                  .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t),
              ))
                  .toList(),
              decoration:
              const InputDecoration(labelText: 'Care Frequency'),
              onChanged: (v) => setState(() => _frequencyType = v),
              validator: (v) =>
              v == null ? 'Choose care frequency' : null,
            ),
            const SizedBox(height: 12),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddPetState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddPetActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddPetState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddPetActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addPet,
          child: const Text('Add Pet'),
        ),
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
            Text('Add New Pet', style: Theme.of(context).textTheme.headlineSmall),
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