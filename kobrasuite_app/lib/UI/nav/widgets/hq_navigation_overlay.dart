import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hq_mode_provider.dart';
import '../../screens/hq/hq_dashboard_screen.dart';
import '../../screens/hq/module_manager_screen.dart';
import '../providers/navigation_store.dart';

class HQNavigationOverlay extends StatelessWidget {
  const HQNavigationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final hqModeProvider = context.watch<HQModeProvider>();
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.7),
        child: hqModeProvider.currentHQView == HQView.Dashboard
            ? const HQDashboardScreen()
            : const ModuleManagerScreen(),
      ),
    );
  }
}