// lib/UI/screens/modules/finances/tabs/transactions_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/finance/transaction_provider.dart';
import '../../../../widgets/cards/finance/transaction_card.dart';
import '../../../../nav/providers/navigation_store.dart';
import '../../../../../models/detail_target.dart';
import '../../../../../models/model_kind_enum.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List _filteredTxs = [];
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final prov = context.read<TransactionProvider>();

    // Warm‑start the local cache from any existing data
    _filteredTxs = List.from(prov.transactions);

    // If no transactions are cached yet, kick off the initial fetch
    if (prov.transactions.isEmpty) {
      // Schedule after build to avoid setState() during build‑phase warnings
      WidgetsBinding.instance.addPostFrameCallback((_) => prov.loadTransactions());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() => context.read<TransactionProvider>().loadTransactions();

  void _filterTxs(String q) {
    final prov = context.read<TransactionProvider>();
    final lower = q.toLowerCase();
    final res = prov.transactions.where((t) {
      final desc = t.description?.toLowerCase() ?? '';
      final type = t.transactionType.toLowerCase();
      final amt = t.amount.toString();
      return desc.contains(lower) || type.contains(lower) || amt.contains(lower);
    }).toList();

    setState(() {
      _searchQuery = q;
      _filteredTxs = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransactionProvider>();
    final isLoading = tp.isLoading;
    final error = tp.errorMessage;
    final txs = _searchQuery.isEmpty ? tp.transactions : _filteredTxs;

    final totalIncome = tp.transactions.fold<double>(0.0, (p, t) => t.amount > 0 ? p + t.amount : p);
    final totalExpense = tp.transactions.fold<double>(0.0, (p, t) => t.amount < 0 ? p + t.amount.abs() : p);

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          _buildSearchField(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: error.isNotEmpty
                  ? ListView(children: [const SizedBox(height: 16), Center(child: Text('Error: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)) ) ])
                  : _buildTxList(context, totalIncome, totalExpense, txs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(labelText: 'Search transactions', border: OutlineInputBorder()),
        onChanged: (v) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () => _filterTxs(v));
        },
      ),
    );
  }

  Widget _buildTxList(BuildContext ctx, double income, double expense, List txs) {
    if (txs.isEmpty) {
      return ListView(children: const [SizedBox(height: 16), Center(child: Text('No transactions found.'))]);
    }

    return ListView(
      children: [
        _buildOverviewCard('Total Income:  \$${income.toStringAsFixed(2)}', 'Sum of all income transactions.'),
        _buildOverviewCard('Total Expenses: \$${expense.toStringAsFixed(2)}', 'Sum of all expense transactions.'),
        const SizedBox(height: 12),
        ...txs.map<Widget>((t) => TransactionCard(
          transaction: t,
          onTap: () => ctx.read<NavigationStore>().showDetail(
            DetailTarget(kind: ModelKind.transaction, id: t.id),
          ),
        )),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String subtitle) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ListTile(title: Text(title), subtitle: Text(subtitle)),
  );
}
