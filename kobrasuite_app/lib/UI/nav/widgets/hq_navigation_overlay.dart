import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hq_mode_provider.dart';
import '../../screens/hq/hq_dashboard_screen.dart';
import '../../screens/hq/module_manager_screen.dart';

class HQNavigationOverlay extends StatefulWidget {
  const HQNavigationOverlay({super.key});

  @override
  State<HQNavigationOverlay> createState() => _HQNavigationOverlayState();
}

class _HQNavigationOverlayState extends State<HQNavigationOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    );
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hqModeProvider = context.watch<HQModeProvider>();
    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation!.value,
          child: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.6)),
              hqModeProvider.currentHQView == null
                  ? const SizedBox()
                  : hqModeProvider.currentHQView == null
                  ? const SizedBox()
                  : hqModeProvider.currentHQView == hqModeProvider.currentHQView
                  ? hqModeProvider.currentHQView.toString() == 'HQView.Dashboard'
                  ? const HQDashboardScreen()
                  : const ModuleManagerScreen()
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}