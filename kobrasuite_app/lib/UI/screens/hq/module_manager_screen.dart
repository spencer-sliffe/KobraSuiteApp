import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nav/providers/navigation_store.dart';

class ModuleManagerScreen extends StatefulWidget {
  const ModuleManagerScreen({super.key});

  @override
  ModuleManagerScreenState createState() => ModuleManagerScreenState();
}

class ModuleManagerScreenState extends State<ModuleManagerScreen> {
  late List<Module> modules;

  @override
  void initState() {
    super.initState();
    modules = Module.values.toList();
  }

  void reorderModules(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = modules.removeAt(oldIndex);
    modules.insert(newIndex, item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NavigationStore>();
    final isManager = store.hqView == HQView.ModuleManager;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF09203F), Color(0xFF537895)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Module Manager',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Drag to Reorder',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: modules.length,
                    onReorder: reorderModules,
                    itemBuilder: (context, index) {
                      final module = modules[index];
                      final label = module.toString().split('.').last;
                      return Container(
                        key: ValueKey(module),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          trailing: const Icon(Icons.drag_handle, color: Colors.white),
                          onTap: () {
                            store.setActiveModule(module);
                            store.setHQActive(false);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (isManager)
                  Text(
                    'Swipe Up/Down or Pinch to switch.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white54),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}