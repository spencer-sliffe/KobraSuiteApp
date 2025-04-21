import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../models/finance/portfolio_stock.dart';
import '../../../../../providers/finance/stock_portfolio_provider.dart';

class StocksTab extends StatefulWidget {
  const StocksTab({Key? key}) : super(key: key);

  @override
  State<StocksTab> createState() => _StocksTabState();
}

class _StocksTabState extends State<StocksTab> {
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();

    // first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockPortfolioProvider>().load();
    });

    // auto‑refresh every 60 s
    _autoRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
      context.read<StockPortfolioProvider>().load();
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockPortfolioProvider>(
      builder: (_, p, __) {
        if (p.isLoading && p.stocks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final theme = Theme.of(context);
        final currency = NumberFormat.simpleCurrency();

        Widget _buildTable() {
          if (p.stocks.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Your portfolio is empty.')),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Ticker')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Shares')),
                DataColumn(label: Text('Price/Share')),
                DataColumn(label: Text('Invested')),
                DataColumn(label: Text('Value')),
                DataColumn(label: Text('P/L')),
                DataColumn(label: Text('P/L %')),
                DataColumn(label: Text('Price (now)')),
                DataColumn(label: Text('Change 24h %')),
                DataColumn(label: Text('Actions')),
              ],
              rows: p.stocks.map((s) {
                Text _colored(String t, bool pos) =>
                    Text(t, style: TextStyle(color: pos ? Colors.green : Colors.red));

                return DataRow(cells: [
                  DataCell(Text(s.ticker)),
                  DataCell(Text(s.name.length > 15 ? '${s.name.substring(0, 15)}…' : s.name)),
                  DataCell(Text(s.numberOfShares.toString())),
                  DataCell(Text(currency.format(s.ppsAtPurchase))),
                  DataCell(Text(currency.format(s.totalInvested))),
                  DataCell(Text(currency.format(s.currentValue))),
                  DataCell(_colored(currency.format(s.profitLoss), s.profitLoss >= 0)),
                  DataCell(_colored('${s.profitLossPct.toStringAsFixed(2)}%', s.profitLossPct >= 0)),
                  DataCell(Text(currency.format(s.closePrice))),
                  DataCell(_colored('${s.percentageChange.toStringAsFixed(2)}%', s.percentageChange >= 0)),
                  DataCell(Row(
                    children: [
                      TextButton(
                        onPressed: () => p.removeStock(s.ticker),
                        child: const Text('Remove'),
                      ),
                      TextButton(
                        onPressed: () => p.fetchStockAnalysis(s.ticker),
                        child: const Text('Analyze'),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        }

        Widget _buildChart() {
          if (p.loadingExtras && p.series.isEmpty) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (p.series.isEmpty) return const SizedBox.shrink();

          final spots = <FlSpot>[];
          for (var i = 0; i < p.series.length; i++) {
            final m = p.series[i];
            spots.add(FlSpot(i.toDouble(), (m['value'] as num).toDouble()));
          }
          final values = spots.map((e) => e.y);
          final minY = values.reduce((a, b) => a < b ? a : b);
          final maxY = values.reduce((a, b) => a > b ? a : b);

          return SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY * 0.95,
                maxY: maxY * 1.05,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (spots.length / 5).ceilToDouble(),
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= p.series.length) return const SizedBox.shrink();
                        final raw = p.series[idx]['Date'];
                        final dt = raw is String ? DateTime.parse(raw) : raw as DateTime;
                        return Text(DateFormat.Md().format(dt), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: (maxY - minY) / 4,
                      getTitlesWidget: (v, _) => Text(
                        NumberFormat.compactCurrency(symbol: '\$').format(v),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        Widget _buildMetrics() {
          if (p.metrics.isEmpty) return const SizedBox.shrink();
          final cards = p.metrics.entries.map((e) {
            final k = e.key;
            final v = e.value;
            final isPct = ['expected_return', 'risk', 'max_drawdown'].contains(k);
            final txt = isPct ? '${(v * 100).toStringAsFixed(2)}%' : v.toStringAsFixed(2);

            return SizedBox(
              width: 140,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(k.replaceAll('_', ' ').toUpperCase(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(txt, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            );
          }).toList();

          return Wrap(spacing: 12, runSpacing: 12, children: cards);
        }

        Widget _buildPortfolioAnalysis() {
          if (p.loadingExtras && p.chat.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (p.chat.isEmpty) return const SizedBox.shrink();
          return Column(
            children: p.chat
                .map((r) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Html(data: r),
            ))
                .toList(),
          );
        }

        Widget _buildStockAnalysis() {
          if (p.stockAnalysis.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const SizedBox(height: 24),
              Text('Stock Analysis', style: theme.textTheme.titleMedium),
              Html(data: p.stockAnalysis),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTable(),
              const SizedBox(height: 24),
              _buildChart(),
              const SizedBox(height: 24),
              _buildMetrics(),
              const SizedBox(height: 24),
              _buildPortfolioAnalysis(),
              _buildStockAnalysis(),
            ],
          ),
        );
      },
    );
  }
}