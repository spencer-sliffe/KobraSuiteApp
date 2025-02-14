import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../screens/main_screen.dart';
import 'navigation_store.dart';

class GlobalGestureDetector extends StatefulWidget {
  final Widget child;
  const GlobalGestureDetector({super.key, required this.child});

  @override
  State<GlobalGestureDetector> createState() => _GlobalGestureDetectorState();
}

class _GlobalGestureDetectorState extends State<GlobalGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController fadeController;
  double initialScale = 1.0;
  double currentScale = 1.0;
  double pinchProgress = 0.0;
  bool isPinching = false;
  double accumulatedScrollDeltaY = 0.0;
  double accumulatedScrollDeltaX = 0.0;
  bool moduleSwitchTriggered = false;
  bool tabSwitchTriggered = false;
  bool hqSubviewSwitchTriggered = false;
  Timer? scrollResetTimer;
  Timer? subviewResetTimer;
  Timer? tabResetTimer;
  final double verticalThreshold = 680.0;
  final double horizontalThreshold = 200.0;
  final double hqSubviewScrollThreshold = 680.0;
  final double pinchInThreshold = 0.85;
  final double pinchOutThreshold = 1.15;
  final double mobileSwipeThreshold = 120.0;
  Offset initialFocalPoint = Offset.zero;
  Offset currentFocalPoint = Offset.zero;

  bool get supportsTrackpad {
    if (kIsWeb) return true;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  bool get usingPanZoom => supportsTrackpad;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    fadeController.dispose();
    scrollResetTimer?.cancel();
    subviewResetTimer?.cancel();
    tabResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return usingPanZoom
        ? Listener(
      onPointerSignal: onPointerSignal,
      onPointerPanZoomStart: onPanZoomStart,
      onPointerPanZoomUpdate: onPanZoomUpdate,
      onPointerPanZoomEnd: onPanZoomEnd,
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: fadeController,
            builder: (context, child) {
              final opacity = pinchProgress.clamp(0.0, 1.0) * fadeController.value;
              return Positioned.fill(
                child: IgnorePointer(
                  ignoring: opacity < 0.01,
                  child: Opacity(
                    opacity: opacity * 0.85,
                    child: Container(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    )
        : Listener(
      onPointerSignal: onPointerSignal,
      child: RawGestureDetector(
        gestures: {
          ScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                () => ScaleGestureRecognizer(supportedDevices: {PointerDeviceKind.touch}),
                (instance) {
              instance
                ..onStart = onScaleStart
                ..onUpdate = onScaleUpdate
                ..onEnd = onScaleEnd;
            },
          ),
        },
        child: Stack(
          children: [
            widget.child,
            AnimatedBuilder(
              animation: fadeController,
              builder: (context, child) {
                final opacity = pinchProgress.clamp(0.0, 1.0) * fadeController.value;
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: opacity < 0.01,
                    child: Opacity(
                      opacity: opacity * 0.85,
                      child: Container(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onPointerSignal(PointerSignalEvent event) {
    if (!supportsTrackpad) return;
    if (event is PointerScrollEvent) {
      final store = context.read<NavigationStore>();
      if (store.hqActive) {
        accumulatedScrollDeltaY += event.scrollDelta.dy;
        if (!hqSubviewSwitchTriggered &&
            accumulatedScrollDeltaY.abs() > hqSubviewScrollThreshold) {
          if (store.hqView == HQView.Dashboard) {
            store.switchHQView(HQView.ModuleManager);
          } else {
            store.switchHQView(HQView.Dashboard);
          }
          HapticFeedback.mediumImpact();
          hqSubviewSwitchTriggered = true;
          subviewResetTimer?.cancel();
          subviewResetTimer = Timer(const Duration(milliseconds: 500), () {
            accumulatedScrollDeltaY = 0.0;
            hqSubviewSwitchTriggered = false;
          });
        }
      } else {
        final dy = event.scrollDelta.dy;
        final dx = event.scrollDelta.dx;
        if (dx.abs() > horizontalThreshold && !tabSwitchTriggered) {
          final mainState = context.findAncestorStateOfType<MainScreenState>();
          if (mainState != null) {
            if (dx < 0) {
              mainState.switchTab(forward: true);
            } else {
              mainState.switchTab(forward: false);
            }
            HapticFeedback.mediumImpact();
            tabSwitchTriggered = true;
            tabResetTimer?.cancel();
            tabResetTimer = Timer(const Duration(milliseconds: 500), () {
              tabSwitchTriggered = false;
            });
          }
        } else if (dy.abs() > verticalThreshold && !moduleSwitchTriggered) {
          final modules = Module.values;
          final idx = modules.indexOf(store.activeModule);
          final forward = dy > 0;
          final nextIdx =
          forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
          store.setActiveModule(modules[nextIdx]);
          HapticFeedback.mediumImpact();
          moduleSwitchTriggered = true;
          scrollResetTimer?.cancel();
          scrollResetTimer = Timer(const Duration(milliseconds: 500), () {
            moduleSwitchTriggered = false;
          });
        }
      }
    }
  }

  void onPanZoomStart(PointerPanZoomStartEvent event) {
    isPinching = true;
    initialScale = 1.0;
    currentScale = 1.0;
    pinchProgress = 0.0;
    fadeController.value = 1.0;
  }

  void onPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (isPinching) {
      currentScale *= event.scale;
      pinchProgress = currentScale < 1.0 ? (1.0 - currentScale) : (currentScale - 1.0);
      setState(() {});
    }
  }

  void onPanZoomEnd(PointerPanZoomEndEvent event) {
    if (isPinching) {
      final store = context.read<NavigationStore>();
      if (currentScale < pinchInThreshold) {
        store.setHQActive(true);
        HapticFeedback.mediumImpact();
      } else if (currentScale > pinchOutThreshold) {
        store.setHQActive(false);
        HapticFeedback.mediumImpact();
      }
      fadeController.reverse(from: 1.0);
      isPinching = false;
      pinchProgress = 0.0;
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    isPinching = true;
    initialScale = 1.0;
    currentScale = 1.0;
    pinchProgress = 0.0;
    initialFocalPoint = details.focalPoint;
    currentFocalPoint = details.focalPoint;
    fadeController.value = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    currentScale = details.scale;
    currentFocalPoint = details.focalPoint;
    pinchProgress =
    currentScale < 1.0 ? (1.0 - currentScale) : (currentScale - 1.0);
    setState(() {});
  }

  void onScaleEnd(ScaleEndDetails details) {
    final store = context.read<NavigationStore>();
    final ratio = currentScale;
    if (ratio < pinchInThreshold) {
      store.setHQActive(true);
      HapticFeedback.mediumImpact();
    } else if (ratio > pinchOutThreshold) {
      store.setHQActive(false);
      HapticFeedback.mediumImpact();
    } else if (ratio >= 0.95 && ratio <= 1.05) {
      final dx = currentFocalPoint.dx - initialFocalPoint.dx;
      final dy = currentFocalPoint.dy - initialFocalPoint.dy;
      if (store.hqActive) {
        if (dy.abs() > mobileSwipeThreshold) {
          if (dy < 0) {
            store.switchHQView(HQView.ModuleManager);
          } else {
            store.switchHQView(HQView.Dashboard);
          }
          HapticFeedback.mediumImpact();
        }
      } else {
        if (dx.abs() > mobileSwipeThreshold) {
          final modules = Module.values;
          final idx = modules.indexOf(store.activeModule);
          final forward = dx < 0;
          final nextIdx =
          forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
          store.setActiveModule(modules[nextIdx]);
          HapticFeedback.mediumImpact();
        }
      }
    }
    fadeController.reverse(from: 1.0);
    isPinching = false;
    pinchProgress = 0.0;
  }
}