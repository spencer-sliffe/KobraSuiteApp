import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_store.dart';

class KobraDrawer extends StatelessWidget {
  const KobraDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationStore = context.watch<NavigationStore>();
    final modules = Module.values;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/house1.svgs'),
            ),
            const SizedBox(height: 8),
            Text('Welcome, User!', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return ListTile(
                    leading: Icon(_getModuleIcon(module)),
                    title: Text(module.toString().split('.').last),
                    selected: module == navigationStore.activeModule,
                    onTap: () {
                      navigationStore.setActiveModule(module);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const Divider(),
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

  IconData _getModuleIcon(Module module) {
    switch (module) {
      case Module.Finances:
        return Icons.account_balance_wallet;
      case Module.HomeLife:
        return Icons.home;
      case Module.School:
        return Icons.school;
      // case Module.Work:
      //   return Icons.work;
    }
  }
}