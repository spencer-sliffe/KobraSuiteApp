import 'package:flutter/material.dart';
import 'package:kobrasuite_app/screens/account/account_screen.dart';
import 'package:kobrasuite_app/screens/account/settings_screen.dart';
import 'package:kobrasuite_app/screens/finances/finances_screen.dart';
import 'package:kobrasuite_app/screens/homelife/homelife_screen.dart';
import 'package:kobrasuite_app/screens/home/home_dashboard_screen.dart';
import 'package:kobrasuite_app/screens/notifications/notifications_screen.dart';
import 'package:kobrasuite_app/screens/school/tabs/school_courses_tab.dart';
import 'package:kobrasuite_app/screens/school/tabs/school_university_tab.dart';
import 'package:kobrasuite_app/screens/work/work_screen.dart';
import 'package:kobrasuite_app/widgets/ai/draggable_chat_overlay.dart';
import 'package:kobrasuite_app/widgets/nav/kobra_drawer.dart';
import 'package:kobrasuite_app/widgets/nav/kobra_nav_rail.dart';

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
    4: _ModuleTabConfig(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    final config = _tabConfigs[_selectedIndex];
    _setupTabController();

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
              const SizedBox(width: 8), // minimal space
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
                // No tab config => show single screen
                    ? _moduleScreens[_selectedIndex]
                    : // If we do have a tab config => show TabBarView
                TabBarView(
                  controller: _moduleTabController,
                  children: config.views,
                ),
              ),
            ],
          ),
          if (_showChatOverlay)
            DraggableChatOverlay(
              onClose: () => setState(() => _showChatOverlay = false),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showChatOverlay = !_showChatOverlay),
        child: const Icon(Icons.chat),
      ),
    );
  }

  /// Builds an inline horizontal TabBar, placed after "KobraSuite" text, with minimal extra space
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

/// For modules that have multiple sub-tabs, we store the tab labels + screens
class _ModuleTabConfig {
  final List<String> tabs;
  final List<Widget> views;
  const _ModuleTabConfig({
    required this.tabs,
    required this.views,
  });
}