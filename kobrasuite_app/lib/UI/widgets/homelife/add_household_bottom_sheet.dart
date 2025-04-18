import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/homelife/household_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddHouseholdState { initial, adding, added }

class AddHouseholdBottomSheet extends StatefulWidget {
  const AddHouseholdBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddHouseholdBottomSheet> createState() =>
      _AddHouseholdBottomSheetState();
}

class _AddHouseholdBottomSheetState extends State<AddHouseholdBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _householdNameController = TextEditingController();

  String _householdType = 'FAMILY';
  AddHouseholdState _state = AddHouseholdState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _householdNameController.dispose();
    super.dispose();
  }

  Future<void> _addHousehold() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddHouseholdState.adding;
      _errorFeedback = "";
    });

    final householdProvider = context.read<HouseholdProvider>();
    final success = await householdProvider.createHousehold(
      householdName: _householdNameController.text.trim(),
      householdType: _householdType,
    );

    if (success) {
      setState(() => _state = AddHouseholdState.added);
    } else {
      setState(() {
        _errorFeedback = ((householdProvider.errorMessage ?? '').isNotEmpty)
            ? householdProvider.errorMessage!
            : 'Failed to add household.';
        _state = AddHouseholdState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddHouseholdState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding household...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddHouseholdState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Household added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    // Normal form
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
            // Household Name
            TextFormField(
              controller: _householdNameController,
              decoration: const InputDecoration(labelText: 'Household Name'),
              validator: (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Enter household name'
                  : null,
            ),
            const SizedBox(height: 12),
            // Type dropdown
            DropdownButtonFormField<String>(
              value: _householdType,
              items: const [
                DropdownMenuItem(value: 'FAMILY', child: Text('Family')),
                DropdownMenuItem(value: 'ROOMMATES', child: Text('Roommates')),
                DropdownMenuItem(value: 'COUPLE', child: Text('Couple')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _householdType = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Household Type'),
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
    if (_state == AddHouseholdState.added) {
      return [
        TextButton(
          onPressed: () => context.read<NavigationStore>().setAddHouseholdActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddHouseholdState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddHouseholdActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addHousehold,
          child: const Text('Add Household'),
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
            Text(
              'Add New Household',
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