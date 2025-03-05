import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/finance/portfolio_stock.dart';
import 'package:kobrasuite_app/models/finance/watchlist_stock.dart';
import 'package:kobrasuite_app/providers/finance/stock_portfolio_provider.dart';
import 'package:kobrasuite_app/providers/finance/stock_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';

class StocksTab extends StatefulWidget {
  const StocksTab({Key? key}) : super(key: key);

  @override
  State<StocksTab> createState() => _StocksTabState();
}

class _StocksTabState extends State<StocksTab> with AutomaticKeepAliveClientMixin {
  late final ControlBarButtonModel _addStockButton;

  @override
  bool get wantKeepAlive => false; // Force disposal

  @override
  void initState() {
    super.initState();
    _addStockButton = ControlBarButtonModel(
      icon: Icons.add,
      label: 'Add Stock',
      onPressed: _showAddStockDialog,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ControlBarProvider>().addEphemeralButton(_addStockButton);
      final portfolioProvider = context.read<StockPortfolioProvider>();
      final watchlistProvider = context.read<StockProvider>();
      await portfolioProvider.loadStockPortfolio();
      await portfolioProvider.loadPortfolioStocks();
      await watchlistProvider.loadWatchlistStocks();
    });
  }

  @override
  void dispose() {
    context.read<ControlBarProvider>().removeEphemeralButton(_addStockButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final portfolioProvider = context.watch<StockPortfolioProvider>();
    final watchlistProvider = context.watch<StockProvider>();

    final isLoading = portfolioProvider.isLoading || watchlistProvider.isLoading;
    final error = portfolioProvider.errorMessage.isNotEmpty
        ? portfolioProvider.errorMessage
        : watchlistProvider.errorMessage;
    final portfolioStocks = portfolioProvider.portfolioStocks;
    final watchlistStocks = watchlistProvider.watchlistStocks;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Stocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...portfolioStocks.map((stock) => Card(
              child: ListTile(
                title: Text(stock.ticker),
                subtitle: Text('${stock.numberOfShares} shares @ ${stock.ppsAtPurchase}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removePortfolioStock(stock),
                ),
              ),
            )),
            const SizedBox(height: 16),
            const Text('Watchlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...watchlistStocks.map((w) => Card(
              child: ListTile(
                title: Text(w.ticker),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeWatchlistStock(w),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddStockDialog(),
    );
  }

  Future<void> _removePortfolioStock(PortfolioStock stock) async {
    final provider = context.read<StockPortfolioProvider>();
    await provider.removeStock(stock.ticker);
  }

  Future<void> _removeWatchlistStock(WatchlistStock stock) async {
    final provider = context.read<StockProvider>();
    await provider.removeWatchlistStock(stock.id);
  }
}

class _AddStockDialog extends StatefulWidget {
  const _AddStockDialog({Key? key}) : super(key: key);

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tickerCtrl = TextEditingController();
  final _sharesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  @override
  void dispose() {
    _tickerCtrl.dispose();
    _sharesCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStock() async {
    if (_formKey.currentState!.validate()) {
      final portfolioProvider = context.read<StockPortfolioProvider>();
      await portfolioProvider.addStock(
        ticker: _tickerCtrl.text,
        shares: double.parse(_sharesCtrl.text),
        purchaseDateIso: _dateCtrl.text.isEmpty ? null : _dateCtrl.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stock'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tickerCtrl,
                decoration: const InputDecoration(labelText: 'Ticker'),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter ticker' : null,
              ),
              TextFormField(
                controller: _sharesCtrl,
                decoration: const InputDecoration(labelText: 'Shares'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter number of shares';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Purchase Date (ISO 8601)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveStock, child: const Text('Save')),
      ],
    );
  }
}