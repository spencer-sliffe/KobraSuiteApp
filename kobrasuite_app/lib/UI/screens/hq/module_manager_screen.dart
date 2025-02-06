/// UI/screens/hq/module_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nav/providers/navigation_store.dart';

class ModuleManagerScreen extends StatefulWidget {
  const ModuleManagerScreen({super.key});

  @override
  State<ModuleManagerScreen> createState() => _ModuleManagerScreenState();
}

class _ModuleManagerScreenState extends State<ModuleManagerScreen> {
  late List<Module> modules;

  @override
  void initState() {
    super.initState();
    modules = Module.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final Module module = modules.removeAt(oldIndex);
            modules.insert(newIndex, module);
          });
        },
        children: [
          for (final module in modules)
            ListTile(
              key: ValueKey(module),
              title: Text(module.toString().split('.').last),
              trailing: const Icon(Icons.drag_handle),
              onTap: () {
                context.read<NavigationStore>().setActiveModule(module);
              },
            )
        ],
      ),
    );
  }
}