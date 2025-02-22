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

import 'modules/finances/tabs/bank_accounts_tab.dart';
import 'modules/finances/tabs/budgets_tab.dart';
import 'modules/finances/tabs/stocks_tab.dart';
import 'modules/finances/tabs/transactions_tab.dart';

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
      final controlBarProvider = context.read<ControlBarProvider>();
      controlBarProvider.clearPersistentButtons();
      controlBarProvider.addPersistentButton(
        ControlBarButtonModel(
          icon: Icons.refresh,
          label: 'Refresh',
          onPressed: () {},
        ),
      );
      controlBarProvider.addPersistentButton(
        ControlBarButtonModel(
          icon: Icons.chat,
          label: 'Toggle AI Chat',
          onPressed: () {},
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final module = context.watch<NavigationStore>().activeModule;
    _tabs = _tabsForModule(module);
    _tabController?.dispose();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      if (tab == 'Accounts') return const BankAccountsTab();
      if (tab == 'Budgets') return const BudgetsTab();
      if (tab == 'Transactions') return const TransactionsTab();
      if (tab == 'Stocks') return const StocksTab();
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
    final navigationStore = context.watch<NavigationStore>();
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final activeModule = navigationStore.activeModule;
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
                    selectedIndex: Module.values.indexOf(activeModule),
                    onDestinationSelected: (index) {
                      context.read<NavigationStore>().setActiveModule(Module.values[index]);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: Module.values.map((m) {
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
            if (navigationStore.hqActive) const HQNavigationOverlay(),
          ],
        ),
        bottomNavigationBar: navigationStore.hqActive ? null : const PageControlBar(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}