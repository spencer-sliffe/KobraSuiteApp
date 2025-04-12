import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'navigation_store.dart';

class GlobalGestureDetector extends StatefulWidget {
  final Widget child;
  const GlobalGestureDetector({super.key, required this.child});

  @override
  State<GlobalGestureDetector> createState() => _GlobalGestureDetectorState();
}

class _GlobalGestureDetectorState extends State<GlobalGestureDetector> {
  Offset initialFocalPoint = Offset.zero;
  Offset currentFocalPoint = Offset.zero;
  double accumulatedScrollDelta = 0.0;
  double accumulatedHQScrollDelta = 0.0;
  bool moduleSwitchTriggered = false;
  bool hqSubviewSwitchTriggered = false;
  Timer? scrollResetTimer;
  Timer? subviewResetTimer;

  final double desktopScrollThreshold = 500.0;
  final double hqSubviewScrollThreshold = 800.0;
  final double mobileSwipeThreshold = 120.0;

  bool get supportsTrackpad {
    if (kIsWeb) return true;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  @override
  void dispose() {
    scrollResetTimer?.cancel();
    subviewResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed overlay and all pinch/zoom-specific widgets.
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: widget.child,
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!supportsTrackpad) return;
    final store = context.read<NavigationStore>();
    if (event is PointerScrollEvent) {
      if (store.hqActive) {
        accumulatedHQScrollDelta += event.scrollDelta.dy;
        if (!hqSubviewSwitchTriggered &&
            accumulatedHQScrollDelta.abs() > hqSubviewScrollThreshold) {
          store.switchHQView(
              store.hqView == HQView.Dashboard ? HQView.ModuleManager : HQView.Dashboard);
          HapticFeedback.mediumImpact();
          hqSubviewSwitchTriggered = true;
          subviewResetTimer?.cancel();
          subviewResetTimer = Timer(const Duration(milliseconds: 500), () {
            accumulatedHQScrollDelta = 0.0;
            hqSubviewSwitchTriggered = false;
          });
        }
      } else {
        accumulatedScrollDelta += event.scrollDelta.dy;
        if (!moduleSwitchTriggered &&
            accumulatedScrollDelta.abs() > desktopScrollThreshold) {
          final modules = context.read<NavigationStore>().moduleOrder;
          final idx = modules.indexOf(store.activeModule);
          final forward = accumulatedScrollDelta > 0;
          final nextIdx =
          forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
          store.setActiveModule(modules[nextIdx]);
          HapticFeedback.mediumImpact();
          moduleSwitchTriggered = true;
          scrollResetTimer?.cancel();
          scrollResetTimer = Timer(const Duration(milliseconds: 500), () {
            accumulatedScrollDelta = 0.0;
            moduleSwitchTriggered = false;
          });
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    initialFocalPoint = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    currentFocalPoint = details.globalPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = currentFocalPoint.dx - initialFocalPoint.dx;
    final dy = currentFocalPoint.dy - initialFocalPoint.dy;
    final store = context.read<NavigationStore>();

    // If HQ is active, vertical swipes switch HQ views.
    if (store.hqActive) {
      if (dy.abs() > mobileSwipeThreshold) {
        store.switchHQView(dy < 0 ? HQView.ModuleManager : HQView.Dashboard);
        HapticFeedback.mediumImpact();
      }
    } else {
      // Otherwise, horizontal swipes switch modules.
      if (dx.abs() > mobileSwipeThreshold) {
        final modules = context.read<NavigationStore>().moduleOrder;
        final idx = modules.indexOf(store.activeModule);
        final forward = dx < 0;
        final nextIdx =
        forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
        store.setActiveModule(modules[nextIdx]);
        HapticFeedback.mediumImpact();
      }
    }
  }
}