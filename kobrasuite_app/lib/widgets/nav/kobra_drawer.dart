import 'package:flutter/material.dart';

class KobraDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const KobraDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = [
      {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Finances', 'icon': Icons.account_balance_wallet},
      {'label': 'Homelife', 'icon': Icons.home},
      {'label': 'Investing', 'icon': Icons.trending_up},
      {'label': 'School', 'icon': Icons.school},
      {'label': 'Work', 'icon': Icons.work},
      {'label': 'Notifications', 'icon': Icons.notifications},
    ];

    return Drawer(
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome, User!',
              style: theme.textTheme.titleMedium,
            ),
            Divider(
              thickness: 1,
              color: theme.dividerColor.withOpacity(0.4),
              height: 24,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  return ListTile(
                    leading: Icon(item['icon'] as IconData),
                    title: Text(item['label'] as String),
                    selected: index == selectedIndex,
                    selectedColor: theme.colorScheme.primary,
                    onTap: () {
                      onItemTap(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            Divider(
              thickness: 1,
              color: theme.dividerColor.withOpacity(0.4),
              height: 24,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}