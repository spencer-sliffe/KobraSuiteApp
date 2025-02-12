import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'navigation_store.dart';

class GlobalGestureDetector extends StatefulWidget {
  final Widget child;
  const GlobalGestureDetector({Key? key, required this.child}) : super(key: key);

  @override
  State<GlobalGestureDetector> createState() => _GlobalGestureDetectorState();
}

class _GlobalGestureDetectorState extends State<GlobalGestureDetector> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  double _initialScale = 1.0;
  double _currentScale = 1.0;
  double _pinchProgress = 0.0;
  bool _isPinching = false;
  double _accumulatedScrollDelta = 0.0;
  bool _moduleSwitchTriggered = false;
  Timer? _scrollResetTimer;
  final double _desktopScrollThreshold = 680.0;
  final double _pinchInThreshold = 0.85;
  final double _pinchOutThreshold = 1.15;
  final double _mobileSwipeThreshold = 120.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _currentFocalPoint = Offset.zero;

  bool get _supportsTrackpad {
    if (kIsWeb) return true;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  bool get _usingPanZoom => _supportsTrackpad;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _usingPanZoom
        ? Listener(
      onPointerSignal: _onPointerSignal,
      onPointerPanZoomStart: _onPanZoomStart,
      onPointerPanZoomUpdate: _onPanZoomUpdate,
      onPointerPanZoomEnd: _onPanZoomEnd,
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              final opacity = (_pinchProgress.clamp(0.0, 1.0)) * _fadeController.value;
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
      onPointerSignal: _onPointerSignal,
      child: RawGestureDetector(
        gestures: {
          ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                () => ScaleGestureRecognizer(supportedDevices: {PointerDeviceKind.touch}),
                (instance) {
              instance
                ..onStart = _onScaleStart
                ..onUpdate = _onScaleUpdate
                ..onEnd = _onScaleEnd;
            },
          ),
        },
        child: Stack(
          children: [
            widget.child,
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                final opacity = (_pinchProgress.clamp(0.0, 1.0)) * _fadeController.value;
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

  void _onPointerSignal(PointerSignalEvent event) {
    if (!_supportsTrackpad) return;
    if (event is PointerScrollEvent) {
      _accumulatedScrollDelta += event.scrollDelta.dy;
      if (!_moduleSwitchTriggered && _accumulatedScrollDelta.abs() > _desktopScrollThreshold) {
        final store = context.read<NavigationStore>();
        final modules = Module.values;
        final idx = modules.indexOf(store.activeModule);
        final forward = _accumulatedScrollDelta > 0;
        final nextIdx = forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
        store.setActiveModule(modules[nextIdx]);
        HapticFeedback.mediumImpact();
        _moduleSwitchTriggered = true;
        _scrollResetTimer?.cancel();
        _scrollResetTimer = Timer(const Duration(milliseconds: 500), () {
          _accumulatedScrollDelta = 0.0;
          _moduleSwitchTriggered = false;
        });
      }
    }
  }

  void _onPanZoomStart(PointerPanZoomStartEvent event) {
    _isPinching = true;
    _initialScale = 1.0;
    _currentScale = 1.0;
    _pinchProgress = 0.0;
    _fadeController.value = 1.0;
  }

  void _onPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (_isPinching) {
      _currentScale *= event.scale;
      _pinchProgress = _currentScale < 1.0 ? (1.0 - _currentScale) : (_currentScale - 1.0);
      setState(() {});
    }
  }

  void _onPanZoomEnd(PointerPanZoomEndEvent event) {
    if (_isPinching) {
      final store = context.read<NavigationStore>();
      if (_currentScale < _pinchInThreshold) {
        store.setHQActive(true);
        HapticFeedback.mediumImpact();
      } else if (_currentScale > _pinchOutThreshold) {
        store.setHQActive(false);
        HapticFeedback.mediumImpact();
      }
      _fadeController.reverse(from: 1.0);
      _isPinching = false;
      _pinchProgress = 0.0;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _isPinching = true;
    _initialScale = 1.0;
    _currentScale = 1.0;
    _pinchProgress = 0.0;
    _initialFocalPoint = details.focalPoint;
    _currentFocalPoint = details.focalPoint;
    _fadeController.value = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _currentScale = details.scale;
    _currentFocalPoint = details.focalPoint;
    _pinchProgress = _currentScale < 1.0 ? (1.0 - _currentScale) : (_currentScale - 1.0);
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    final store = context.read<NavigationStore>();
    final ratio = _currentScale;
    if (ratio < _pinchInThreshold) {
      store.setHQActive(true);
      HapticFeedback.mediumImpact();
    } else if (ratio > _pinchOutThreshold) {
      store.setHQActive(false);
      HapticFeedback.mediumImpact();
    } else if (ratio >= 0.95 && ratio <= 1.05) {
      final dx = _currentFocalPoint.dx - _initialFocalPoint.dx;
      if (dx.abs() > _mobileSwipeThreshold) {
        final modules = Module.values;
        final idx = modules.indexOf(store.activeModule);
        final forward = dx < 0;
        final nextIdx = forward ? (idx + 1) % modules.length : (idx - 1 + modules.length) % modules.length;
        store.setActiveModule(modules[nextIdx]);
        HapticFeedback.mediumImpact();
      }
    }
    _fadeController.reverse(from: 1.0);
    _isPinching = false;
    _pinchProgress = 0.0;
  }
}