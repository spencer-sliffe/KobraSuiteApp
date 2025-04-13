import 'package:flutter/material.dart';
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
import '../../providers/finance/bank_account_provider.dart';
import '../../providers/finance/budget_provider.dart';
import '../nav/overlays/universal_overlay.dart';
import '../nav/providers/control_bar_registrar.dart';
import 'modules/homelife/tabs/homelife_calendar_tab.dart';
import 'modules/homelife/tabs/homelife_chores_tab.dart';
import 'modules/homelife/tabs/homelife_household_tab.dart';
import 'modules/homelife/tabs/homelife_medical_tab.dart';
import 'modules/work/tabs/work_teams_tabs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tabs = [];
  Module? _currentModule;

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
            // This pulls the correct callback from the active tab:
            context.read<NavigationStore>().refreshCallback?.call();
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
    _tabController!.animateTo(activeIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
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
    final Module newModule = store.activeModule;
    if (_currentModule != newModule) {
      // Module has changed. Recreate the TabController and update the tab list.
      _currentModule = newModule;
      _tabs = _tabsForModule(newModule);
      _tabController?.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
      switch (newModule) {
        case Module.Finances:
          _setupTabController(
            activeIndex: store.activeFinancesTabIndex,
            updateStoreIndex: (newIndex) =>
                store.setActiveFinancesTabIndex(newIndex),
          );
          break;
        case Module.School:
          _setupTabController(
            activeIndex: store.activeSchoolTabIndex,
            updateStoreIndex: (newIndex) =>
                store.setActiveSchoolTabIndex(newIndex),
          );
          break;
        case Module.HomeLife:
          _setupTabController(
            activeIndex: store.activeHomeLifeTabIndex,
            updateStoreIndex: (newIndex) =>
                store.setActiveHomeLifeTabIndex(newIndex),
          );
          break;
        case Module.Work:
          _setupTabController(
            activeIndex: store.activeWorkTabIndex,
            updateStoreIndex: (newIndex) =>
                store.setActiveWorkTabIndex(newIndex),
          );
          break;
      }
    } else {
      // Module has not changed. Animate tab index transitions if needed.
      int newIndex = 0;
      switch (newModule) {
        case Module.Finances:
          newIndex = store.activeFinancesTabIndex;
          break;
        case Module.School:
          newIndex = store.activeSchoolTabIndex;
          break;
        case Module.HomeLife:
          newIndex = store.activeHomeLifeTabIndex;
          break;
        case Module.Work:
          newIndex = store.activeWorkTabIndex;
          break;
      }
      if (_tabController != null && _tabController!.index != newIndex) {
        _tabController!.animateTo(newIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      }
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
        return ['Personal', 'Chores', 'Meals', 'Household', 'Medical'];
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
        case 'Personal':
          return ControlBarRegistrar(
            homelifeTabIndex: 0,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_calendar_add',
                icon: Icons.add,
                label: 'Calendar Event',
                onPressed: () {
                  context.read<NavigationStore>().setAddCalendarEventActive();
                },
              ),
              ControlBarButtonModel(
                id: 'homelife_workout_routine_add',
                icon: Icons.add,
                label: 'Workout Routine',
                onPressed: () {
                  context.read<NavigationStore>().setAddWorkoutRoutineActive();
                },
              ),
            ],
            child: const HomelifeCalendarTab(),
          );
        case 'Chores':
          return ControlBarRegistrar(
            homelifeTabIndex: 1,
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
              ControlBarButtonModel(
                id: 'homelife_grocery_item_add',
                icon: Icons.add,
                label: 'Grocery Item',
                onPressed: () {
                  context.read<NavigationStore>().setAddGroceryItemActive();
                },
              ),
              ControlBarButtonModel(
                id: 'homelife_grocery_list_add',
                icon: Icons.add,
                label: 'Grocery List',
                onPressed: () {
                  context.read<NavigationStore>().setAddGroceryListActive();
                },
              ),
            ],
            child: const HomelifeMealsTab(),
          );
        case 'Household':
          return ControlBarRegistrar(
            homelifeTabIndex: 3,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_pet_add',
                icon: Icons.add,
                label: 'Pet',
                onPressed: () {
                  context.read<NavigationStore>().setAddPetActive();
                },
              ),
              ControlBarButtonModel(
                id: 'homelife_child_account_add',
                icon: Icons.add,
                label: 'Child Profile',
                onPressed: () {
                  context.read<NavigationStore>().setAddChildProfileActive();
                },
              ),
            ],
            child: const HomelifeHouseholdTab(),
          );
        case 'Medical':
          return ControlBarRegistrar(
            homelifeTabIndex: 4,
            buttons: [
              ControlBarButtonModel(
                id: 'homelife_medication_add',
                icon: Icons.add,
                label: 'Medication',
                onPressed: () {
                  context.read<NavigationStore>().setAddMedicationActive();
                },
              ),
              ControlBarButtonModel(
                id: 'homelife_medical_appointment_add',
                icon: Icons.add,
                label: 'Medical Appointment',
                onPressed: () {
                  context
                      .read<NavigationStore>()
                      .setAddMedicalAppointmentActive();
                },
              ),
            ],
            child: const HomelifeMedicalTab(),
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
            ],
            child: const BankAccountsTab(),
          );
        case 'Budgets':
          return ControlBarRegistrar(
            financeTabIndex: 2,
            refreshCallback: () async {
              final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
              await budgetProvider.loadBudgets();
            },
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
                      context
                          .read<ControlBarProvider>()
                          .clearEphemeralButtons();
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
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: TabBarView(
                            key: ValueKey(_currentModule),
                            controller: _tabController,
                            children: _tabs
                                .map((t) => _buildTabContent(t, activeModule))
                                .toList(),
                          ),
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
