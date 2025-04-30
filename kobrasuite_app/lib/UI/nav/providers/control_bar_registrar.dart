// lib/UI/nav/providers/control_bar_registrar.dart
//
// Handles:
//
//   • Registering / removing the *ephemeral* control‑bar buttons that
//     belong to a single tab.
//   • Wiring the tab’s refresh handler to the global “Refresh” icon.
//
// ────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'control_bar_provider.dart';
import 'navigation_store.dart';

class ControlBarRegistrar extends StatefulWidget {
  const ControlBarRegistrar({
    super.key,
    required this.buttons,
    required this.child,
    this.financeTabIndex,
    this.workTabIndex,
    this.homelifeTabIndex,
    this.schoolTabIndex,
    this.refreshCallback,
  });

  /// Buttons that should appear only while *this* tab is visible.
  final List<ControlBarButtonModel> buttons;

  /// Tab content.
  final Widget child;

  /// Zero‑based index of the tab inside its module.
  final int? financeTabIndex, workTabIndex, homelifeTabIndex, schoolTabIndex;

  /// Async routine to execute when the user taps the persistent
  /// “Refresh” button in the control bar.
  final Future<void> Function()? refreshCallback;

  @override
  State<ControlBarRegistrar> createState() => _ControlBarRegistrarState();
}

// ────────────────────────────────────────────────────────────────

class _ControlBarRegistrarState extends State<ControlBarRegistrar> {
  late final NavigationStore _nav = context.read<NavigationStore>();
  late final ControlBarProvider _bar = context.read<ControlBarProvider>();

  /// IDs of buttons we have inserted into the bar.
  final Set<String> _registeredIds = {};

  /// Listener that reacts to navigation changes.
  late final VoidCallback _navListener = _syncWithNavigation;

  // Wraps an async refresh function into a plain `void Function()`.
  VoidCallback? get _refreshWrapper => widget.refreshCallback == null
      ? null
      : () {
    // Fire‑and‑forget; UI already shows its own loading indicator.
    widget.refreshCallback!();
  };

  // ────────────────────────────────────────────────────────────── lifecycle

  @override
  void initState() {
    super.initState();
    _nav.addListener(_navListener);

    // First sync after the initial build frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWithNavigation());
  }

  @override
  void didUpdateWidget(covariant ControlBarRegistrar old) {
    super.didUpdateWidget(old);

    // If the button list or refresh callback changed, resync.
    if (old.buttons != widget.buttons ||
        old.refreshCallback != widget.refreshCallback) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncWithNavigation());
    }
  }

  @override
  void dispose() {
    _nav.removeListener(_navListener);

    // Remove any buttons we added, but only if they are still present.
    for (final id in _registeredIds) {
      final idx = widget.buttons.indexWhere((b) => b.id == id);
      if (idx != -1) _bar.removeEphemeralButton(widget.buttons[idx]);
    }

    // Clear the refresh handler if we were the owner.
    if (_refreshWrapper != null &&
        identical(_nav.refreshCallback, _refreshWrapper)) {
      _nav.clearRefreshCallback();
    }

    super.dispose();
  }

  // ────────────────────────────────────────────────────────────── core logic

  /// Is *this* tab the one currently displayed?
  bool get _isActive {
    switch (_nav.activeModule) {
      case Module.Finances:
        return widget.financeTabIndex == _nav.activeFinancesTabIndex;
      // case Module.Work:
      //   return widget.workTabIndex == _nav.activeWorkTabIndex;
      case Module.HomeLife:
        return widget.homelifeTabIndex == _nav.activeHomeLifeTabIndex;
      case Module.School:
        return widget.schoolTabIndex == _nav.activeSchoolTabIndex;
    }
  }

  void _syncWithNavigation() {
    // 1. Refresh handler
    if (_isActive) {
      if (_refreshWrapper != null) _nav.setRefreshCallback(_refreshWrapper!);
    } else {
      if (_refreshWrapper != null &&
          identical(_nav.refreshCallback, _refreshWrapper)) {
        _nav.clearRefreshCallback();
      }
    }

    // 2. Ephemeral buttons
    if (_isActive) {
      for (final b in widget.buttons) {
        if (_registeredIds.add(b.id)) _bar.addEphemeralButton(b);
      }
    } else {
      for (final b in widget.buttons) {
        if (_registeredIds.remove(b.id)) _bar.removeEphemeralButton(b);
      }
    }
  }

  // ────────────────────────────────────────────────────────────── build

  @override
  Widget build(BuildContext context) => widget.child;
}