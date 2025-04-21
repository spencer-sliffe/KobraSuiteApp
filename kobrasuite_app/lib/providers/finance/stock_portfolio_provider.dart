import 'package:flutter/foundation.dart';
import '../../models/finance/portfolio_stock.dart';
import '../../services/finance/stock_portfolio_service.dart';
import '../../services/service_locator.dart';
import '../general/finance_profile_provider.dart';

/// Keeps the *one‑per‑FinanceProfile* stock portfolio in sync with the backend
/// and exposes derived analytics (metrics, chat, value series, etc.).
class StockPortfolioProvider extends ChangeNotifier {
  /* ────────────────────────────────────────────────────────── */
  final StockPortfolioService _svc = serviceLocator<StockPortfolioService>();

  /// The injected “parent” provider; all user / profile IDs come from here.
  FinanceProfileProvider _financeProfileProvider;

  /// Primary‑key of the portfolio *table row*.  Equal to the `financeProfilePk`
  /// once a portfolio has been created.
  int _stockPortfolioPk;

  StockPortfolioProvider({
    required FinanceProfileProvider financeProfileProvider,
    required int stockPortfolioPk,
  })  : _financeProfileProvider = financeProfileProvider,
        _stockPortfolioPk = stockPortfolioPk == 0
            ? financeProfileProvider.financeProfilePk
            : stockPortfolioPk;

  /* ────────── convenience getters pulled from the parent ────────── */
  int get userPk           => _financeProfileProvider.userPk;
  int get userProfilePk    => _financeProfileProvider.userProfilePk;
  int get financeProfilePk => _financeProfileProvider.financeProfilePk;
  int get stockPortfolioPk => _stockPortfolioPk;

  /* ───────────────────────── state exposed to UI ────────────────── */
  bool  _loading       = false;
  bool  _loadingExtras = false;
  String _error        = '';

  List<PortfolioStock>        _stocks       = [];
  Map<String, double>         _metrics      = {};
  List<String>                _chat         = [];
  List<Map<String, dynamic>>  _series       = [];
  String                       _analysis    = '';

  bool get isLoading      => _loading;
  bool get loadingExtras  => _loadingExtras;
  String get error        => _error;
  List<PortfolioStock>       get stocks   => _stocks;
  Map<String, double>        get metrics  => _metrics;
  List<String>               get chat     => _chat;
  List<Map<String, dynamic>> get series   => _series;
  String                      get stockAnalysis => _analysis;

  /* ───────────────── injected updates (ProxyProvider.update) ─────── */
  void update({
    required FinanceProfileProvider newFinanceProfileProvider,
    required int newStockPortfolioPk,
  }) {
    _financeProfileProvider = newFinanceProfileProvider;
    _stockPortfolioPk = newStockPortfolioPk == 0
        ? newFinanceProfileProvider.financeProfilePk
        : newStockPortfolioPk;
  }

  /* ───────────────────────── portfolio life‑cycle ────────────────── */
  Future<bool> createPortfolio() async {
    _loading = true; notifyListeners();

    final ok = await _svc.createStockPortfolio(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
    );

    if (ok) {
      _stockPortfolioPk = financeProfilePk;   // pk == finance_profile_id
      await load();
    }

    _loading = false; notifyListeners();
    return ok;
  }

  Future<void> load() async {
    _loading = true; _error = ''; notifyListeners();

    _stocks = await _svc.getPortfolioStocks(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
    );

    _loading = false; notifyListeners();

    if (_stocks.isNotEmpty) await _loadExtras();
  }

  Future<void> _loadExtras() async {
    _loadingExtras = true; notifyListeners();

    _metrics = await _svc.getPortfolioMetrics(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
    );

    _chat = await _svc.getPortfolioChat(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
    );

    _series = await _svc.getPortfolioValueSeries(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
    );

    _loadingExtras = false; notifyListeners();
  }

  /* ───────────────────────── stock mutations ─────────────────────── */
  Future<bool> addStock(String ticker, double shares,
      {String? purchaseDateIso}) async {
    _loading = true; notifyListeners();

    final ok = await _svc.addStock(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
      ticker:           ticker,
      numShares:        shares,
      purchaseDateIso:  purchaseDateIso,
    );

    if (ok) await load();

    _loading = false; notifyListeners();
    return ok;
  }

  Future<bool> removeStock(String ticker) async {
    _loading = true; notifyListeners();

    final ok = await _svc.removeStock(
      userPk:           userPk,
      userProfilePk:    userProfilePk,
      financeProfilePk: financeProfilePk,
      ticker:           ticker,
    );

    if (ok) await load();

    _loading = false; notifyListeners();
    return ok;
  }

  /* ────────────────────────── analysis helpers ───────────────────── */
  Future<void> fetchStockAnalysis(String ticker) async {
    _analysis = ''; notifyListeners();
    _analysis = await _svc.getStockAnalysis(ticker);
    notifyListeners();
  }

  void clearStockAnalysis() {
    _analysis = ''; notifyListeners();
  }
}