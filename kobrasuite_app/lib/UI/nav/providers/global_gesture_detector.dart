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

class _GlobalGestureDetectorState extends State<GlobalGestureDetector> with SingleTickerProviderStateMixin {
  late AnimationController fadeController;
  double initialScale = 1.0;
  double currentScale = 1.0;
  double pinchProgress = 0.0;
  bool isPinching = false;
  double accumulatedScrollDelta = 0.0;
  double accumulatedHQScrollDelta = 0.0;
  bool moduleSwitchTriggered = false;
  bool hqSubviewSwitchTriggered = false;
  Timer? scrollResetTimer;
  Timer? subviewResetTimer;
  // Increased thresholds to 800.0 for less sensitive swiping.
  final double desktopScrollThreshold = 800.0;
  final double hqSubviewScrollThreshold = 800.0;
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

  bool get usingPanZoom => kIsWeb ? false : supportsTrackpad;

  @override
  void initState() {
    super.initState();
    // Increase fade duration for a smoother fade in/out.
    fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    fadeController.dispose();
    scrollResetTimer?.cancel();
    subviewResetTimer?.cancel();
    super.dispose();
  }

  Widget _buildOverlay() {
    return AnimatedBuilder(
      animation: fadeController,
      builder: (context, child) {
        final opacity = (pinchProgress.clamp(0.0, 1.0)) * fadeController.value;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlay = _buildOverlay();
    if (usingPanZoom) {
      return Listener(
        onPointerSignal: _handlePointerSignal,
        onPointerPanZoomStart: _onPanZoomStart,
        onPointerPanZoomUpdate: _onPanZoomUpdate,
        onPointerPanZoomEnd: _onPanZoomEnd,
        child: Stack(children: [widget.child, overlay]),
      );
    }
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: RawGestureDetector(
        gestures: {
          ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                () => ScaleGestureRecognizer(supportedDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad}),
                (instance) {
              instance
                ..onStart = _onScaleStart
                ..onUpdate = _onScaleUpdate
                ..onEnd = _onScaleEnd;
            },
          ),
        },
        child: Stack(children: [widget.child, overlay]),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!supportsTrackpad) return;
    final store = context.read<NavigationStore>();
    if (event is PointerScrollEvent) {
      if (store.hqActive) {
        accumulatedHQScrollDelta += event.scrollDelta.dy;
        if (!hqSubviewSwitchTriggered && accumulatedHQScrollDelta.abs() > hqSubviewScrollThreshold) {
          store.switchHQView(store.hqView == HQView.Dashboard ? HQView.ModuleManager : HQView.Dashboard);
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
        if (!moduleSwitchTriggered && accumulatedScrollDelta.abs() > desktopScrollThreshold) {
          final modules = context.read<NavigationStore>().moduleOrder;
          final idx = modules.indexOf(store.activeModule);
          final forward = accumulatedScrollDelta > 0;
          final nextIdx = forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
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

  void _onPanZoomStart(PointerPanZoomStartEvent event) {
    isPinching = true;
    initialScale = 1.0;
    currentScale = 1.0;
    pinchProgress = 0.0;
    fadeController.value = 1.0;
  }

  void _onPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (isPinching) {
      // Use the instantaneous scale provided by the event instead of multiplying.
      currentScale = event.scale;
      pinchProgress = currentScale < 1.0 ? (1.0 - currentScale) : (currentScale - 1.0);
      setState(() {});
    }
  }

  void _onPanZoomEnd(PointerPanZoomEndEvent event) {
    if (isPinching) {
      _handlePinchCompletion(currentScale);
      fadeController.reverse(from: 1.0);
      isPinching = false;
      pinchProgress = 0.0;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    isPinching = true;
    initialScale = 1.0;
    currentScale = 1.0;
    pinchProgress = 0.0;
    initialFocalPoint = details.focalPoint;
    currentFocalPoint = details.focalPoint;
    fadeController.value = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    currentScale = details.scale;
    currentFocalPoint = details.focalPoint;
    pinchProgress = currentScale < 1.0 ? (1.0 - currentScale) : (currentScale - 1.0);
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (isPinching) {
      if (currentScale >= 0.95 && currentScale <= 1.05) {
        final dx = currentFocalPoint.dx - initialFocalPoint.dx;
        final dy = currentFocalPoint.dy - initialFocalPoint.dy;
        final store = context.read<NavigationStore>();
        if (store.hqActive) {
          if (dy.abs() > mobileSwipeThreshold) {
            store.switchHQView(dy < 0 ? HQView.ModuleManager : HQView.Dashboard);
            HapticFeedback.mediumImpact();
          }
        } else {
          if (dx.abs() > mobileSwipeThreshold) {
            final modules = context.read<NavigationStore>().moduleOrder;
            final idx = modules.indexOf(store.activeModule);
            final forward = dx < 0;
            final nextIdx = forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
            store.setActiveModule(modules[nextIdx]);
            HapticFeedback.mediumImpact();
          }
        }
      } else {
        _handlePinchCompletion(currentScale);
      }
      fadeController.reverse(from: 1.0);
      isPinching = false;
      pinchProgress = 0.0;
    }
  }

  void _handlePinchCompletion(double scale) {
    final store = context.read<NavigationStore>();
    if (scale < pinchInThreshold) {
      store.toggleHQ();
      HapticFeedback.mediumImpact();
    } else if (scale > pinchOutThreshold) {
      store.toggleHQ();
      HapticFeedback.mediumImpact();
    }
  }
}