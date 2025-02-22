import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/finance/stock_portfolio_provider.dart';
import 'package:kobrasuite_app/providers/finance/stock_provider.dart';
import 'package:kobrasuite_app/models/finance/portfolio_stock.dart';

import '../../../../../models/finance/watchlist_stock.dart';

class StocksTab extends StatefulWidget {
  const StocksTab({Key? key}) : super(key: key);

  @override
  State<StocksTab> createState() => _StocksTabState();
}

class _StocksTabState extends State<StocksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final portfolioProvider = context.read<StockPortfolioProvider>();
      final watchlistProvider = context.read<StockProvider>();
      await portfolioProvider.loadStockPortfolio();
      await portfolioProvider.loadPortfolioStocks();
      await watchlistProvider.loadWatchlistStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<StockPortfolioProvider>();
    final watchlistProvider = context.watch<StockProvider>();

    final isLoading = portfolioProvider.isLoading || watchlistProvider.isLoading;
    final error = portfolioProvider.errorMessage.isNotEmpty
        ? portfolioProvider.errorMessage
        : watchlistProvider.errorMessage;
    final portfolioStocks = portfolioProvider.portfolioStocks;
    final watchlistStocks = watchlistProvider.watchlistStocks;

    return Scaffold(
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (!isLoading && error.isEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('My Stocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...portfolioStocks.map((stock) => ListTile(
                      title: Text('${stock.ticker}'),
                      subtitle: Text('${stock.numberOfShares} shares @ ${stock.ppsAtPurchase}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removePortfolioStock(stock),
                      ),
                    )),
                    const Divider(),
                    const Text('Watchlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...watchlistStocks.map((w) => ListTile(
                      title: Text(w.ticker),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeWatchlistStock(w),
                      ),
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStockDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tickerCtrl = TextEditingController();
        final sharesCtrl = TextEditingController();
        final dateCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Add Stock'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: tickerCtrl, decoration: const InputDecoration(labelText: 'Ticker')),
                TextField(controller: sharesCtrl, decoration: const InputDecoration(labelText: 'Shares')),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Purchase Date (ISO 8601)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final portfolioProvider = context.read<StockPortfolioProvider>();
                final success = await portfolioProvider.addStock(
                  ticker: tickerCtrl.text,
                  shares: double.tryParse(sharesCtrl.text) ?? 1.0,
                  purchaseDateIso: dateCtrl.text.isEmpty ? null : dateCtrl.text,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removePortfolioStock(PortfolioStock stock) async {
    final provider = context.read<StockPortfolioProvider>();
    await provider.removeStock(stock.ticker);
  }

  Future<void> _removeWatchlistStock(WatchlistStock w) async {
    final provider = context.read<StockProvider>();
    await provider.removeWatchlistStock(w.ticker);
  }
}