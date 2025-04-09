import 'package:flutter/material.dart';
import 'package:kobrasuite_app/UI/screens/modules/homelife/tabs/homelife_groceries_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/homelife/tabs/homelife_meals_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/work/tabs/work_projects_tabs.dart';
import 'package:kobrasuite_app/UI/screens/modules/work/tabs/work_tasks_tab.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';
import 'package:kobrasuite_app/UI/nav/widgets/hq_navigation_overlay.dart';
import 'package:kobrasuite_app/UI/nav/providers/global_gesture_detector.dart';
import 'package:kobrasuite_app/UI/nav/widgets/kobra_drawer.dart';
import 'package:kobrasuite_app/UI/nav/control_bar/page_control_bar.dart';
import 'package:kobrasuite_app/UI/screens/modules/school/tabs/school_university_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/school/tabs/school_courses_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/bank_accounts_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/budgets_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/transactions_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/stocks_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/overview_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/budget_categories_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/analysis_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/news_tab.dart';
import 'package:kobrasuite_app/UI/screens/modules/finances/tabs/watchlist_tab.dart';
import '../nav/overlays/universal_overlay.dart';
import '../nav/providers/control_bar_registrar.dart';
import 'modules/homelife/tabs/homelife_calendar_tab.dart';
import 'modules/homelife/tabs/homelife_chores_tab.dart';
import 'modules/work/tabs/work_teams_tabs.dart';

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
          id: 'refresh',
          icon: Icons.refresh,
          label: 'Refresh',
          onPressed: () {
          },
        ),
      );
      provider.addPersistentButton(
        ControlBarButtonModel(
          id: 'chat',
          icon: Icons.chat,
          label: 'Toggle AI Chat',
          onPressed: () {
            context.read<NavigationStore>().setAIChatActive();
          },
        ),
      );
      provider.addPersistentButton(
        ControlBarButtonModel(
          id: 'hq',
          icon: Icons.hd,
          label: 'HQ',
          onPressed: () {
            context.read<NavigationStore>().toggleHQ();
          },
        ),
      );
    });
  }

  void _setupTabController({
    required int activeIndex,
    required void Function(int) updateStoreIndex,
  }) {
    _tabController!.index = activeIndex;
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        context.read<ControlBarProvider>().clearEphemeralButtons();
        updateStoreIndex(_tabController!.index);
      }
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
    switch (module) {
      case Module.Finances:
        _setupTabController(
          activeIndex: store.activeFinancesTabIndex,
          updateStoreIndex: (newIndex) => store.setActiveFinancesTabIndex(newIndex),
        );
        break;
      case Module.School:
        _setupTabController(
          activeIndex: store.activeSchoolTabIndex,
          updateStoreIndex: (newIndex) => store.setActiveSchoolTabIndex(newIndex),
        );
        break;
      case Module.HomeLife:
        _setupTabController(
          activeIndex: store.activeHomeLifeTabIndex,
          updateStoreIndex: (newIndex) => store.setActiveHomeLifeTabIndex(newIndex),
        );
        break;
      case Module.Work:
        _setupTabController(
          activeIndex: store.activeWorkTabIndex,
          updateStoreIndex: (newIndex) => store.setActiveWorkTabIndex(newIndex),
        );
        break;
    }
  }

  List<String> _tabsForModule(Module module) {
    switch (module) {
      case Module.School:
        return ['University', 'Courses'];
      case Module.Work:
        return ['Projects', 'Teams', 'Tasks'];
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
        return ['Chores', 'Calendar', 'Meals', 'Groceries'];
    }
  }

  Widget _inlineTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: theme.colorScheme.secondary,
      unselectedLabelColor: theme.appBarTheme.foregroundColor ?? Colors.white70,
      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildTabContent(String tab, Module module) {
    if (module == Module.School) {
      switch (tab) {
        case 'University':
          return ControlBarRegistrar(
            schoolTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                id: 'school_university_search',
                icon: Icons.search,
                label: 'Universities',
                onPressed: () {
                  context.read<NavigationStore>().setSearchUniversityActive();
                },
              ),
            ],
            child: const SchoolUniversityTab(),
          );
        case 'Courses':
          return ControlBarRegistrar(
            schoolTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                id: 'school_course_add',
                icon: Icons.add,
                label: 'Course',
                onPressed: () {
                  context.read<NavigationStore>().setAddCourseActive();
                },
              ),
            ],
            child: const SchoolCoursesTab(),
          );
        default:
          return Container();
      }
    } else if (module == Module.Work) {
      switch (tab) {
        case 'Projects':
          return ControlBarRegistrar(
            workTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                id: 'work_project_add',
                icon: Icons.add,
                label: 'Project',
                onPressed: () {
                  context.read<NavigationStore>().setAddProjectActive();
                },
              ),
            ],
            child: const WorkProjectsTab(),
          );
        case 'Teams':
          return ControlBarRegistrar(
            workTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                id: 'work_team_add',
                icon: Icons.add,
                label: 'Team',
                onPressed: () {
                  context.read<NavigationStore>().setAddTeamActive();
                },
              ),
            ],
            child: const WorkTeamsTab(),
          );
        case 'Tasks':
          return ControlBarRegistrar(
            workTabIndex: 2,
            buttons: [
              ControlBarButtonModel(
                id: 'work_task_add',
                icon: Icons.add,
                label: 'Task',
                onPressed: () {
                  context.read<NavigationStore>().setAddTaskActive();
                },
              ),
            ],
            child: const WorkTasksTab(),
          );
        default:
          return Container();
      }
    } else if (module == Module.HomeLife) {
      switch (tab) {
        case 'Chores':
          return ControlBarRegistrar(
            homelifeTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_chores_add',
                icon: Icons.add,
                label: 'Chore',
                onPressed: () {
                  context.read<NavigationStore>().setAddChoreActive();
                },
              ),
            ],
            child: const HomelifeChoresTab(),
          );
        case 'Calendar':
          return ControlBarRegistrar(
            homelifeTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_calendar_add',
                icon: Icons.add,
                label: 'Calendar Event',
                onPressed: () {
                  context.read<NavigationStore>().setAddCalendarEventActive();
                },
              ),
            ],
            child: const HomelifeCalendarTab(),
          );
        case 'Meals':
          return ControlBarRegistrar(
            homelifeTabIndex: 2,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_meals_add',
                icon: Icons.add,
                label: 'Meal',
                onPressed: () {
                  context.read<NavigationStore>().setAddMealActive();
                },
              ),
            ],
            child: const HomelifeMealsTab(),
          );
        case 'Groceries':
          return ControlBarRegistrar(
            homelifeTabIndex: 3,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_groceries_add',
                icon: Icons.add,
                label: 'Grocery',
                onPressed: () {
                  context.read<NavigationStore>().setAddGroceryItemActive();
                },
              ),
            ],
            child: const HomelifeGroceriesTab(),
          );
        default:
          return Container();
      }
    } else if (module == Module.Finances) {
      switch (tab) {
        case 'Overview':
          return ControlBarRegistrar(
            financeTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_overview_sync',
                icon: Icons.sync,
                label: 'Overview',
                onPressed: () {
                  context.read<NavigationStore>().setSyncFinanceOverviewActive();
                },
              ),
            ],
            child: const OverviewTab(),
          );
        case 'Accounts':
          return ControlBarRegistrar(
            financeTabIndex: 1,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_account_add',
                icon: Icons.add,
                label: 'Account',
                onPressed: () {
                  context.read<NavigationStore>().setAddBankAccountActive();
                },
              ),
              ControlBarButtonModel(
                id: 'finances_accounts_sync',
                icon: Icons.sync,
                label: 'Accounts',
                onPressed: () {
                  context.read<NavigationStore>().setSyncFinanceAccountsActive();
                },
              ),
            ],
            child: const BankAccountsTab(),
          );
        case 'Budgets':
          return ControlBarRegistrar(
            financeTabIndex: 2,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_budget_add',
                icon: Icons.add,
                label: 'Budget',
                onPressed: () {
                  context.read<NavigationStore>().setAddBudgetActive();
                },
              ),
            ],
            child: const BudgetsTab(),
          );
        case 'Categories':
          return ControlBarRegistrar(
            financeTabIndex: 3,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_category_add',
                icon: Icons.add,
                label: 'Category',
                onPressed: () {
                  context.read<NavigationStore>().setAddCategoryActive();
                },
              ),
            ],
            child: const BudgetCategoriesTab(),
          );
        case 'Transactions':
          return ControlBarRegistrar(
            financeTabIndex: 4,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_transaction_add',
                icon: Icons.add,
                label: 'Transaction',
                onPressed: () {
                  context.read<NavigationStore>().setAddTransactionActive();
                },
              ),
              ControlBarButtonModel(
                id: 'finances_transactions_sync',
                icon: Icons.sync,
                label: 'Transactions',
                onPressed: () {
                  context.read<NavigationStore>().setSyncFinanceTransactionsActive();

                },
              ),
            ],
            child: const TransactionsTab(),
          );
        case 'Stocks':
          return ControlBarRegistrar(
            financeTabIndex: 5,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_stock_add',
                icon: Icons.add,
                label: 'Stock',
                onPressed: () {
                  context.read<NavigationStore>().setAddStockActive();
                },
              ),
              ControlBarButtonModel(
                id: 'finances_stocks_sync',
                icon: Icons.sync,
                label: 'Stocks',
                onPressed: () {
                  context.read<NavigationStore>().setSyncStocksActive();
                },
              ),
              ControlBarButtonModel(
                id: 'finances_stock_portfolio_add',
                icon: Icons.add,
                label: 'Portfolio',
                onPressed: () {
                  context.read<NavigationStore>().setAddStockPortfolioActive();
                },
              ),
            ],
            child: const StocksTab(),
          );
        case 'Watchlist':
          return ControlBarRegistrar(
            financeTabIndex: 6,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_watchlist_add',
                icon: Icons.add_alert,
                label: 'Add to Watchlist',
                onPressed: () {
                  context.read<NavigationStore>().setAddWatchlistStockActive();
                },
              ),
            ],
            child: const WatchlistTab(),
          );
        case 'Analysis':
          return ControlBarRegistrar(
            financeTabIndex: 7,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_analysis_run',
                icon: Icons.analytics,
                label: 'Run Analysis',
                onPressed: () {
                  context.read<NavigationStore>().setRunFinanceAnalysisActive();
                },
              ),
            ],
            child: const AnalysisTab(),
          );
        case 'News':
          return ControlBarRegistrar(
            financeTabIndex: 8,
            buttons: [
              ControlBarButtonModel(
                id: 'finances_news_refresh',
                icon: Icons.newspaper,
                label: 'Refresh News',
                onPressed: () {
                  context.read<NavigationStore>().setRefreshFinanceNewsActive();
                },
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
                      context.read<ControlBarProvider>().clearEphemeralButtons();
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
                  child: _tabController != null
                      ? TabBarView(
                    controller: _tabController,
                    children: _tabs.map((t) => _buildTabContent(t, activeModule)).toList(),
                  )
                      : Container(),
                ),
              ],
            ),
            // Insert the GlobalModalsLauncher here.
            const UniversalOverlay(),
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