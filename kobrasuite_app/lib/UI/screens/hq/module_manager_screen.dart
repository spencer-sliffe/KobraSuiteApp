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
  void didChangeDependencies() {
    super.didChangeDependencies();
    modules = List.from(context.watch<NavigationStore>().moduleOrder);
  }

  void reorderModules(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = modules.removeAt(oldIndex);
    modules.insert(newIndex, item);
    context.read<NavigationStore>().setModuleOrder(modules);
    setState(() {});
  }

  Widget moduleCard(Module module) {
    final label = module.toString().split('.').last;
    return InkWell(
      onTap: () {
        context.read<NavigationStore>().setActiveModule(module);
        context.read<NavigationStore>().setHQActive(false);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            const Icon(Icons.drag_indicator, color: Colors.white),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget moduleTownView(Module module) {
    return Container(
      width: 100,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          module.toString().split('.').last,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
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
                colors: [Color(0xFF1C2E4A), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'HQ Module Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reorder & Explore Modules',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: modules.length,
                      onReorder: reorderModules,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return Container(
                          key: ValueKey(module),
                          child: moduleCard(module),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: modules.map(moduleTownView).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isManager)
                    Text(
                      'Swipe Up/Down or Pinch to switch.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}