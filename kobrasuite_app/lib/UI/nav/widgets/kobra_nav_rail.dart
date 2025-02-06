/// UI/nav/widgets/kobra_nav_rail.dart

import 'package:flutter/material.dart';

class KobraNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const KobraNavRail({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = [
      {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Finances', 'icon': Icons.account_balance_wallet},
      {'label': 'Homelife', 'icon': Icons.home},
      {'label': 'School', 'icon': Icons.school},
      {'label': 'Work', 'icon': Icons.work},
      {'label': 'Notifications', 'icon': Icons.notifications},
    ];

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTap,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surface,
      selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      destinations: navItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item['icon'] as IconData),
          selectedIcon: Icon(item['icon'] as IconData, color: theme.colorScheme.primary),
          label: Text(
            item['label'] as String,
            style: const TextStyle(fontSize: 9),
          ),
        );
      }).toList(),
    );
  }
}