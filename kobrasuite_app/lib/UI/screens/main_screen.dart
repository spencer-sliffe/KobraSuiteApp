// lib/UI/screens/main_screen.dart

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
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/overview_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/budget_categories_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/analysis_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/news_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/watchlist_tab.dart';

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
      // Add some persistent control bar buttons
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
      // Set the tab to store.activeFinancesTabIndex
      _tabController!.index = store.activeFinancesTabIndex;
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          // Clear ephemeral from old tab
          context.read<ControlBarProvider>().clearEphemeralButtons();
          // Update store
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
        return [
          'Overview',
          'Accounts',
          'Budgets',
          'Categories',
          'Transactions',
          'Stocks',
          'Watchlist',
          'Analysis',
          'News',
        ];
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
      if (tab == 'University') return const SchoolUniversityTab();
      if (tab == 'Courses') return const SchoolCoursesTab();
      return Container();
    } else if (module == Module.Work) {
      return const WorkScreen();
    } else if (module == Module.HomeLife) {
      return const HomelifeScreen();
    } else if (module == Module.Finances) {
      switch (tab) {
        case 'Overview':
          return const OverviewTab();

        case 'Accounts':
          return ControlBarRegistrar(
            financeTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Account',
                onPressed: () {},
              ),
            ],
            child: const BankAccountsTab(),
          );

        case 'Budgets':
          return ControlBarRegistrar(
            financeTabIndex: 2,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Budget',
                onPressed: () {},
              ),
            ],
            child: const BudgetsTab(),
          );

        case 'Categories':
          return ControlBarRegistrar(
            financeTabIndex: 3,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Category',
                onPressed: () {},
              ),
            ],
            child: const BudgetCategoriesTab(),
          );

        case 'Transactions':
          return ControlBarRegistrar(
            financeTabIndex: 4,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Transaction',
                onPressed: () {},
              ),
            ],
            child: const TransactionsTab(),
          );

        case 'Stocks':
          return ControlBarRegistrar(
            financeTabIndex: 5,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add,
                label: 'Add Stock',
                onPressed: () {},
              ),
            ],
            child: const StocksTab(),
          );

        case 'Watchlist':
          return ControlBarRegistrar(
            financeTabIndex: 6,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.add_alert,
                label: 'Add to Watchlist',
                onPressed: () {},
              ),
            ],
            child: const WatchlistTab(),
          );

        case 'Analysis':
          return ControlBarRegistrar(
            financeTabIndex: 7,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.analytics,
                label: 'Run Analysis',
                onPressed: () {},
              ),
            ],
            child: const AnalysisTab(),
          );

        case 'News':
          return ControlBarRegistrar(
            financeTabIndex: 8,
            buttons: [
              ControlBarButtonModel(
                icon: Icons.newspaper,
                label: 'Refresh News',
                onPressed: () {},
              ),
            ],
            child: const NewsTab(),
          );

        default:
          return Container();
      }
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
                    onDestinationSelected: (index) {
                      // Clear ephemeral from old module
                      context.read<ControlBarProvider>().clearEphemeralButtons();
                      // Switch modules
                      store.setActiveModule(modules[index]);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: modules.map((m) {
                      return NavigationRailDestination(
                        icon: Icon(_moduleIcon(m)),
                        label: Text(m.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                Expanded(
                  child: (_tabController != null)
                      ? TabBarView(
                    controller: _tabController,
                    children: _tabs.map((t) => _buildTabContent(t, activeModule)).toList(),
                  )
                      : Container(),
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