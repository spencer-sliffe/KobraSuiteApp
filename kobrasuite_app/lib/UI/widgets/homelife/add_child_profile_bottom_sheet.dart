import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';
import 'package:kobrasuite_app/providers/homelife/child_profile_provider.dart';

enum AddChildProfileState { initial, adding, added }

class AddChildProfileBottomSheet extends StatefulWidget {
  const AddChildProfileBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddChildProfileBottomSheet> createState() => _AddChildProfileBottomSheetState();
}

class _AddChildProfileBottomSheetState extends State<AddChildProfileBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  AddChildProfileState _state = AddChildProfileState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _childNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 18);
    final lastDate = now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      final year = pickedDate.year.toString().padLeft(4, '0');
      final month = pickedDate.month.toString().padLeft(2, '0');
      final day = pickedDate.day.toString().padLeft(2, '0');
      controller.text = '$year-$month-$day';
    }
  }

  Future<void> _addChildProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddChildProfileState.adding;
      _errorFeedback = "";
    });

    final childProfileProvider = context.read<ChildProfileProvider>();
    final success = await childProfileProvider.createChildProfile(
      name: _childNameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
    );

    if (success) {
      setState(() => _state = AddChildProfileState.added);
    } else {
      setState(() {
        _errorFeedback = 'Failed to add child profile.';
        _state = AddChildProfileState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddChildProfileState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding child profile...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddChildProfileState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Child profile added successfully.',
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
            TextFormField(
              controller: _childNameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter child name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dateOfBirthController,
              readOnly: true,
              onTap: () => _pickDate(_dateOfBirthController),
              decoration: const InputDecoration(
                labelText: 'Date of Birth (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter date of birth' : null,
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
    if (_state == AddChildProfileState.added) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddChildProfileActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddChildProfileState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddChildProfileActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addChildProfile,
          child: const Text('Add Child'),
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
              'Add New Child Profile',
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
