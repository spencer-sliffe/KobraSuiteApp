import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_store.dart';

class GlobalGestureDetector extends StatefulWidget {
  final Widget child;
  const GlobalGestureDetector({super.key, required this.child});

  @override
  State<GlobalGestureDetector> createState() => _GlobalGestureDetectorState();
}

class _GlobalGestureDetectorState extends State<GlobalGestureDetector> {
  Offset _initialFocalPoint = Offset.zero;
  Offset _currentFocalPoint = Offset.zero;
  double _initialScale = 1.0;
  double _currentScale = 1.0;

  // We’ll store the accumulated scroll offset from trackpad signals
  double _trackpadScrollOffset = 0.0;

  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // We intercept scroll signals for 2-finger trackpad swipes
      onPointerSignal: _onPointerSignal,
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          ScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                () => ScaleGestureRecognizer(
              debugOwner: this,
              supportedDevices: _isDesktopOrWeb
                  ? {
                PointerDeviceKind.touch,
                PointerDeviceKind.trackpad,
                // If you want pinch from mouse wheels (rare):
                // PointerDeviceKind.mouse,
              }
                  : {PointerDeviceKind.touch},
            ),
                (ScaleGestureRecognizer instance) {
              instance
                ..onStart = _onScaleStart
                ..onUpdate = _onScaleUpdate
                ..onEnd = _onScaleEnd
              // Because your Flutter version is >= 3.10,
              // trackpad pinch will be recognized if the OS sends pinch events
                ..trackpadScrollCausesScale = _isDesktopOrWeb
                ..trackpadScrollToScaleFactor = const Offset(0.001, 0.001);
            },
          ),
        },
        child: widget.child,
      ),
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    final navigationStore = context.read<NavigationStore>();
    // Only handle pointer signals if on desktop or web
    if (!_isDesktopOrWeb) return;

    // If user 2-fingers scrolls the trackpad, we get a PointerScrollEvent with scrollDelta
    if (event is PointerScrollEvent) {
      // We accumulate the vertical delta
      _trackpadScrollOffset += event.scrollDelta.dy;

      // If user scrolls up/down enough, interpret as a 2-finger vertical swipe
      if (_trackpadScrollOffset.abs() > 80) {
        if (navigationStore.isHQActive) {
          // Switch HQ subview
          _switchHQView(navigationStore, up: _trackpadScrollOffset < 0);
        } else {
          // Switch modules
          _navigateModule(navigationStore, forward: _trackpadScrollOffset < 0);
        }
        // Reset offset
        _trackpadScrollOffset = 0.0;
      }
    }
  }

  // ------------------- Scale (Pinch) handling -------------------
  //---------------  Pinch motion should activate HQ --------------
  //---------------- Zoom motion should deactivate HQ -------------
  void _onScaleStart(ScaleStartDetails details) {
    _initialFocalPoint = details.focalPoint;
    _currentFocalPoint = details.focalPoint;
    _initialScale = 1.0;
    _currentScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _currentFocalPoint = details.focalPoint;
    _currentScale = details.scale;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    final navigationStore = context.read<NavigationStore>();

    final scaleRatio = _currentScale / _initialScale;
    if (scaleRatio < 0.95) {
      navigationStore.setHQActive(true);
    } else if (scaleRatio > 1.05) {
      navigationStore.setHQActive(false);
    }

    if (!_isDesktopOrWeb) {
      final dx = _currentFocalPoint.dx - _initialFocalPoint.dx;
      final dy = _currentFocalPoint.dy - _initialFocalPoint.dy;
      if (dx.abs() > 80 && dy.abs() < 80) {
        _navigateModule(navigationStore, forward: dx < 0);
      }
    }
  }

  // ------------------- Module switching -------------------
  void _navigateModule(NavigationStore store, {required bool forward}) {
    final modules = Module.values;
    final currentIndex = modules.indexOf(store.activeModule);
    final nextIndex = forward
        ? (currentIndex + 1) % modules.length
        : (currentIndex - 1 + modules.length) % modules.length;
    store.setActiveModule(modules[nextIndex]);
  }

  void _switchHQView(NavigationStore store, {required bool up}) {
    store.switchHQView(up ? HQView.Dashboard : HQView.ModuleManager);
  }
}