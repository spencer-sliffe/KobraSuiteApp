import 'package:flutter/material.dart';
import 'package:kobrasuite_app/UI/screens/account/account_screen.dart';
import 'package:kobrasuite_app/UI/screens/account/settings_screen.dart';
import 'package:kobrasuite_app/UI/screens/finances/finances_screen.dart';
import 'package:kobrasuite_app/UI/screens/homelife/homelife_screen.dart';
import 'package:kobrasuite_app/UI/screens/home/home_dashboard_screen.dart';
import 'package:kobrasuite_app/UI/screens/notifications/notifications_screen.dart';
import 'package:kobrasuite_app/UI/screens/school/tabs/school_courses_tab.dart';
import 'package:kobrasuite_app/UI/screens/school/tabs/school_university_tab.dart';
import 'package:kobrasuite_app/UI/screens/work/work_screen.dart';
import 'package:kobrasuite_app/UI/nav/kobra_drawer.dart';
import 'package:kobrasuite_app/UI/nav/kobra_nav_rail.dart';
import 'package:provider/provider.dart';

import '../../widgets/control_bar/page_control_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showChatOverlay = false;
  late final List<Widget> _moduleScreens;

  final Map<int, _ModuleTabConfig> _tabConfigs = {
    3: _ModuleTabConfig(
      tabs: ['University', 'Courses'],
      views: [
        SchoolUniversityTab(userId: 0),
        SchoolCoursesTab(),
      ],
    ),
  };

  TabController? _moduleTabController;

  @override
  void initState() {
    super.initState();
    _moduleScreens = [
      HomeDashboardScreen(onModuleSelected: (idx) => setState(() => _selectedIndex = idx)),
      const FinancesScreen(),
      const HomelifeScreen(),
      Container(color: Colors.transparent),
      const WorkScreen(),
      const NotificationsScreen(),
    ];
    _setupTabController();
  }

  @override
  void dispose() {
    _moduleTabController?.dispose();
    super.dispose();
  }

  void _setupTabController() {
    final config = _tabConfigs[_selectedIndex];
    if (config == null) {
      _moduleTabController?.dispose();
      _moduleTabController = null;
    } else {
      _moduleTabController?.dispose();
      _moduleTabController = TabController(
        length: config.tabs.length,
        vsync: this,
      );
    }
  }

  void _goToAccountScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
  }

  void _goToSettingsScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _goToNotificationsScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final config = _tabConfigs[_selectedIndex];
    _setupTabController();

    // For the bottom control bar, we pass callbacks based on the active module.
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.flutter_dash, size: 28),
            const SizedBox(width: 8),
            const Text('KobraSuite'),
            if (config != null) ...[
              const SizedBox(width: 8),
              _buildInlineTabBar(config, theme),
            ],
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: _goToAccountScreen,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      drawer: isLargeScreen
          ? null
          : KobraDrawer(
        selectedIndex: _selectedIndex,
        onItemTap: (index) {
          if (index == -1) {
            _goToSettingsScreen();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
      body: Stack(
        children: [
          Row(
            children: [
              if (isLargeScreen)
                Container(
                  width: 80,
                  color: theme.colorScheme.surface,
                  child: Column(
                    children: [
                      Expanded(
                        child: KobraNavRail(
                          selectedIndex: _selectedIndex,
                          onItemTap: (index) => setState(() => _selectedIndex = index),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _goToSettingsScreen,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              Expanded(
                child: config == null
                    ? _moduleScreens[_selectedIndex]
                    : TabBarView(
                  controller: _moduleTabController,
                  children: config.views,
                ),
              ),
            ],
          ),
          // Chat overlay if needed.
          // (This could be refined further.)
        ],
      ),
      bottomNavigationBar: PageControlBar(
        selectedIndex: _selectedIndex,
        schoolSubTabIndex: config != null ? _moduleTabController?.index : null,
        onAiChatToggle: () {
          // TODO: Implement AI chat toggle.
        },
        onRefresh: () {
          // TODO: Implement refresh action based on active module.
        },
        onUniversityChatToggle: () {
          // TODO: Implement university chat toggle.
        },
        onSetUniversity: () {
          // TODO: Implement set as my university.
        },
        onCourseChatToggle: () {
          // TODO: Implement course chat toggle.
        },
        onAddCourse: () {
          // TODO: Implement add course.
        },
        onAssignmentChatToggle: () {
          // TODO: Implement assignment chat toggle.
        },
      ),
    );
  }

  Widget _buildInlineTabBar(_ModuleTabConfig config, ThemeData theme) {
    return TabBar(
      controller: _moduleTabController,
      isScrollable: true,
      dividerColor: Colors.transparent,
      labelColor: theme.colorScheme.secondary,
      unselectedLabelColor: theme.appBarTheme.foregroundColor ?? Colors.white70,
      tabs: config.tabs.map((tab) => Tab(text: tab)).toList(),
      tabAlignment: TabAlignment.start,
    );
  }
}

class _ModuleTabConfig {
  final List<String> tabs;
  final List<Widget> views;
  const _ModuleTabConfig({
    required this.tabs,
    required this.views,
  });
}