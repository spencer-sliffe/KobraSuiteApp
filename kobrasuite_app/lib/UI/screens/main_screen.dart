import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';
import 'package:kobrasuite_app/UI/nav/widgets/hq_navigation_overlay.dart';
import 'package:kobrasuite_app/UI/nav/providers/global_gesture_detector.dart';
import 'package:kobrasuite_app/UI/nav/widgets/kobra_drawer.dart';
import 'package:kobrasuite_app/UI/nav/control_bar/page_control_bar.dart';
import 'package:kobrasuite_app/UI/screens/modules/school/tabs/school_university_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/school/tabs/school_courses_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/work/work_screen.dart';
import 'package:kobrasuite_app/UI/screens/modules/homelife/homelife_screen.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/bank_accounts_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/budgets_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/transactions_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/stocks_tab.dart';
import '../nav/providers/control_bar_registrar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ControlBarProvider>();
      provider.clearPersistentButtons();
      provider.addPersistentButton(
        ControlBarButtonModel(
          icon: Icons.refresh,
          label: 'Refresh',
          onPressed: () {},
        ),
      );
      provider.addPersistentButton(
        ControlBarButtonModel(
          icon: Icons.chat,
          label: 'Toggle AI Chat',
          onPressed: () {},
        ),
      );
      provider.addPersistentButton(
        ControlBarButtonModel(
          icon: Icons.hd,
          label: 'HQ',
          onPressed: () {
            context.read<NavigationStore>().setHQActive(true);
          },
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.watch<NavigationStore>();
    final module = store.activeModule;
    _tabs = _tabsForModule(module);
    _tabController?.dispose();
    _tabController = TabController(length: _tabs.length, vsync: this);
    if (module == Module.Finances) {
      _tabController!.index = store.activeFinancesTabIndex;
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          store.setActiveFinancesTabIndex(_tabController!.index);
        }
      });
    }
  }

  List<String> _tabsForModule(Module module) {
    switch (module) {
      case Module.School:
        return ['University', 'Courses'];
      case Module.Work:
        return ['Work'];
      case Module.Finances:
        return ['Accounts', 'Budgets', 'Transactions', 'Stocks'];
      case Module.HomeLife:
        return ['HomeLife'];
    }
  }

  Widget _inlineTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: theme.colorScheme.secondary,
      unselectedLabelColor: theme.appBarTheme.foregroundColor ?? Colors.white70,
      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildTabContent(String tab, Module module) {
    if (module == Module.School) {
      if (tab == 'University') return const SchoolUniversityTab(userId: 0);
      if (tab == 'Courses') return const SchoolCoursesTab();
    } else if (module == Module.Work) {
      return const WorkScreen();
    } else if (module == Module.Finances) {
      switch (tab) {
        case 'Accounts':
          return ControlBarRegistrar(
            financeTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Account',
                onPressed: () {
                  // showDialog(context: context, builder: (_) => const AddBankAccountDialog());
                },
              ),
            ],
            child: const BankAccountsTab(),
          );
        case 'Budgets':
          return ControlBarRegistrar(
            financeTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Budget',
                onPressed: () {
                  // showDialog(context: context, builder: (_) => const AddBudgetDialog());
                },
              ),
            ],
            child: const BudgetsTab(),
          );
        case 'Transactions':
          return ControlBarRegistrar(
            financeTabIndex: 2,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Transaction',
                onPressed: () {
                  // showDialog(context: context, builder: (_) => const AddTransactionDialog());
                },
              ),
            ],
            child: const TransactionsTab(),
          );
        case 'Stocks':
          return ControlBarRegistrar(
            financeTabIndex: 3,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Stock',
                onPressed: () {
                  // showDialog(context: context, builder: (_) => const AddStockDialog());
                },
              ),
            ],
            child: const StocksTab(),
          );
      }
    } else if (module == Module.HomeLife) {
      return const HomelifeScreen();
    }
    return Container();
  }

  IconData _moduleIcon(Module module) {
    switch (module) {
      case Module.Finances:
        return Icons.account_balance_wallet;
      case Module.HomeLife:
        return Icons.home;
      case Module.School:
        return Icons.school;
      case Module.Work:
        return Icons.work;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NavigationStore>();
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final activeModule = store.activeModule;
    final modules = store.moduleOrder;
    final theme = Theme.of(context);

    return GlobalGestureDetector(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.flutter_dash, size: 28),
              const SizedBox(width: 8),
              const Text('KobraSuite'),
              if (_tabs.isNotEmpty) ...[
                const SizedBox(width: 8),
                _inlineTabBar(theme),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => Navigator.pushNamed(context, '/account'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        drawer: isLargeScreen ? null : const KobraDrawer(),
        body: Stack(
          children: [
            Row(
              children: [
                if (isLargeScreen)
                  NavigationRail(
                    selectedIndex: modules.indexOf(activeModule),
                    onDestinationSelected: (index) =>
                        store.setActiveModule(modules[index]),
                    labelType: NavigationRailLabelType.all,
                    destinations: modules.map((m) {
                      return NavigationRailDestination(
                        icon: Icon(_moduleIcon(m)),
                        label: Text(m.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((t) => _buildTabContent(t, activeModule)).toList(),
                  ),
                ),
              ],
            ),
            if (store.hqActive) const HQNavigationOverlay(),
          ],
        ),
        bottomNavigationBar: store.hqActive ? null : const PageControlBar(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}