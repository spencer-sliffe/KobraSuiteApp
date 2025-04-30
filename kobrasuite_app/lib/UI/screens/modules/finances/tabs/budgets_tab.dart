// lib/UI/screens/modules/finances/tabs/budgets_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/finance/budget_provider.dart';
import '../../../../widgets/cards/finance/budget_card.dart';
import '../../../../nav/providers/navigation_store.dart';
import '../../../../../models/detail_target.dart';
import '../../../../../models/model_kind_enum.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({Key? key}) : super(key: key);

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  List _filteredBudgets = [];
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredBudgets = List.from(context.read<BudgetProvider>().budgets);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() => context.read<BudgetProvider>().loadBudgets();

  void _filterBudgets(String q) {
    final provider = context.read<BudgetProvider>();
    final lower = q.toLowerCase();
    final res = provider.budgets.where((b) => b.name.toLowerCase().contains(lower)).toList();
    setState(() {
      _searchQuery = q;
      _filteredBudgets = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BudgetProvider>();
    final isLoading = bp.isLoading;
    final err = bp.errorMessage ?? '';
    final budgets = _searchQuery.isEmpty ? bp.budgets : _filteredBudgets;
    final total = bp.budgets.fold<double>(0.0, (p, b) => p + b.totalAmount);

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search budgets', border: OutlineInputBorder()),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () => _filterBudgets(v));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Total Budget: \$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: err.isNotEmpty
                  ? ListView(children: [const SizedBox(height: 16), Center(child: Text('Error: $err', style: TextStyle(color: Theme.of(context).colorScheme.error)) ) ])
                  : _listView(context, budgets),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listView(BuildContext ctx, List budgets) {
    if (budgets.isEmpty) {
      return ListView(children: const [SizedBox(height: 16), Center(child: Text('No budgets found.'))]);
    }
    return ListView(
      children: budgets.map<Widget>((b) => BudgetCard(
        budget: b,
        onTap: () => ctx.read<NavigationStore>().showDetail(
          DetailTarget(kind: ModelKind.budget, id: b.id),
        ),
        onDelete: () {/* optional */},
      )).toList(),
    );
  }
}