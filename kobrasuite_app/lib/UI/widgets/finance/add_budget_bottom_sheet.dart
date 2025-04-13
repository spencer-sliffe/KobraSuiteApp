import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:provider/provider.dart';
import '../../../providers/finance/budget_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddBudgetState { initial, adding, added }

class AddBudgetBottomSheet extends StatefulWidget {
  const AddBudgetBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _budgetNameController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isActive = true;
  AddBudgetState _state = AddBudgetState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _budgetNameController.dispose();
    _totalAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _addBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddBudgetState.adding;
      _errorFeedback = "";
    });

    final budgetProvider = context.read<BudgetProvider>();

    final name = _budgetNameController.text.trim();
    // Remove '$' before parsing
    final rawAmount =
    _totalAmountController.text.replaceAll('\$', '').trim();
    final totalAmount = double.tryParse(rawAmount) ?? 0.0;
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();

    final success = await budgetProvider.createBudget(
      name: name,
      totalAmount: totalAmount,
      startDate: startDate,
      endDate: endDate,
      isActive: _isActive,
    );

    if (success) {
      setState(() {
        _state = AddBudgetState.added;
      });
    } else {
      setState(() {
        _errorFeedback = ((budgetProvider.errorMessage ?? '').isNotEmpty)
            ? budgetProvider.errorMessage!
            : 'Failed to add budget.';
        _state = AddBudgetState.initial;
      });
    }
  }

  /// Opens a calendar picker to set the date on the given controller.
  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5); // 5 years in the past
    final lastDate = DateTime(now.year + 5);  // 5 years in the future

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      // Format as YYYY-MM-DD
      final year = pickedDate.year.toString().padLeft(4, '0');
      final month = pickedDate.month.toString().padLeft(2, '0');
      final day = pickedDate.day.toString().padLeft(2, '0');
      controller.text = '$year-$month-$day';
    }
  }

  Widget _buildContent() {
    if (_state == AddBudgetState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding budget...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddBudgetState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Budget added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    // Default: show the form.
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
            // Budget Name
            TextFormField(
              controller: _budgetNameController,
              decoration: const InputDecoration(labelText: 'Budget Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a budget name'
                  : null,
            ),
            const SizedBox(height: 12),

            // Total Amount (formatted as currency with two decimals)
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                prefixText: '\$', // Shows the "$" symbol.
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter total amount';
                }
                final rawAmount = value.replaceAll('\$', '').trim();
                if (double.tryParse(rawAmount) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Start Date field with date picker.
            TextFormField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _pickDate(_startDateController),
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter start date' : null,
            ),
            const SizedBox(height: 12),

            // End Date field with date picker.
            TextFormField(
              controller: _endDateController,
              readOnly: true,
              onTap: () => _pickDate(_endDateController),
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter end date' : null,
            ),
            const SizedBox(height: 12),

            // Active toggle
            Row(
              children: [
                const Text('Active:'),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display error feedback if any.
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
    if (_state == AddBudgetState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddBudgetState.initial) {
      return [
        TextButton(
          onPressed: () =>
              context.read<NavigationStore>().setAddBudgetActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addBudget,
          child: const Text('Add Budget'),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Budget',
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