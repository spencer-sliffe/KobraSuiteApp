import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/finance/stock_portfolio_provider.dart';
import '../../nav/providers/navigation_store.dart';

/// Internal UI state
enum _SheetState { initial, adding, added }

class AddPortfolioStockBottomSheet extends StatefulWidget {
  const AddPortfolioStockBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddPortfolioStockBottomSheet> createState() =>
      _AddPortfolioStockBottomSheetState();
}

class _AddPortfolioStockBottomSheetState
    extends State<AddPortfolioStockBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _tickerCtrl  = TextEditingController();
  final _sharesCtrl  = TextEditingController();

  DateTime? _purchaseDate;
  _SheetState _state = _SheetState.initial;
  String _err = '';

  @override
  void dispose() {
    _tickerCtrl.dispose();
    _sharesCtrl.dispose();
    super.dispose();
  }

  /* ─────────────────────────────────────────────────────────── */
  Future<void> _chooseDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate : DateTime(2000),
      lastDate  : DateTime.now(),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;
    setState(() {
      _purchaseDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  /* ─────────────────────────────────────────────────────────── */
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = _SheetState.adding;
      _err   = '';
    });

    final prov   = context.read<StockPortfolioProvider>();
    final ticker = _tickerCtrl.text.trim().toUpperCase();
    final shares = double.parse(_sharesCtrl.text.trim());

    final ok = await prov.addStock(
      ticker,
      shares,
      purchaseDateIso: _purchaseDate?.toIso8601String(),
    );

    if (ok) {
      setState(() => _state = _SheetState.added);
    } else {
      setState(() {
        _state = _SheetState.initial;
        _err   = 'Failed to add stock – please try again.';
      });
    }
  }

  /* ─────────────────────────────────────────────────────────── */
  Widget _buildBody() {
    switch (_state) {
      case _SheetState.adding:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        );

      case _SheetState.added:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Stock added to portfolio!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        );

      default:
        final fmt = DateFormat.yMd().add_jm();
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left : 12,
              right: 12,
              top  : 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tickerCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Ticker'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a ticker' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sharesCtrl,
                  decoration: const InputDecoration(labelText: 'Number of shares'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter shares';
                    final d = double.tryParse(v.trim());
                    if (d == null || d <= 0) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _chooseDateTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Purchase date & time (optional)',
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _purchaseDate == null
                            ? 'Tap to select'
                            : fmt.format(_purchaseDate!),
                      ),
                    ),
                  ),
                ),
                if (_err.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_err,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.red)),
                ],
              ],
            ),
          ),
        );
    }
  }

  List<Widget> _buildActions() {
    switch (_state) {
      case _SheetState.added:
        return [
          TextButton(
            onPressed: () =>
                context.read<NavigationStore>().setAddStockActive(),
            child: const Text('Close'),
          ),
        ];

      case _SheetState.initial:
        return [
          TextButton(
            onPressed: () =>
                context.read<NavigationStore>().setAddStockActive(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Add'),
          ),
        ];

      default:
        return [];
    }
  }

  /* ─────────────────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Stock to Portfolio',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildBody(),
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