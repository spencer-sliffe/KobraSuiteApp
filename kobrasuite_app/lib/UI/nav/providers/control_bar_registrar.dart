// lib/UI/nav/providers/control_bar_registrar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/control_bar_provider.dart';
import 'package:kobrasuite_app/UI/nav/providers/navigation_store.dart';

class ControlBarRegistrar extends StatefulWidget {
  final List<ControlBarButtonModel> buttons;
  final Widget child;
  final int? financeTabIndex;
  final int? workTabIndex;
  final int? homelifeTabIndex;
  final int? schoolTabIndex;

  const ControlBarRegistrar({
    super.key,
    required this.buttons,
    required this.child,
    this.financeTabIndex,
    this.schoolTabIndex,
    this.workTabIndex,
    this.homelifeTabIndex,
  });

  @override
  State<ControlBarRegistrar> createState() => _ControlBarRegistrarState();
}

class _ControlBarRegistrarState extends State<ControlBarRegistrar> {
  bool _buttonsAdded = false;
  late NavigationStore _navStore;
  late ControlBarProvider _controlBarProvider;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _navStore = context.read<NavigationStore>();
    _controlBarProvider = context.read<ControlBarProvider>();
    _listener = _updateButtons;

    // Listen for changes in NavigationStore so we know if the user
    // switched modules/tabs
    _navStore.addListener(_listener);

    // Run once after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtons());
  }

  void _updateButtons() {
    final module = _navStore.activeModule;
    bool shouldShow = false;

    if (widget.financeTabIndex != null && module == Module.Finances) {
      shouldShow = (_navStore.activeFinancesTabIndex == widget.financeTabIndex);
    }
    if (widget.schoolTabIndex != null && module == Module.School) {
      shouldShow = (_navStore.activeSchoolTabIndex == widget.schoolTabIndex);
    }
    if (widget.workTabIndex != null && module == Module.Work) {
      shouldShow = (_navStore.activeWorkTabIndex == widget.workTabIndex);
    }
    if (widget.homelifeTabIndex != null && module == Module.HomeLife) {
      shouldShow = (_navStore.activeHomeLifeTabIndex == widget.homelifeTabIndex);
    }

    if (shouldShow && !_buttonsAdded) {
      // We want these ephemeral buttons, but haven't added them yet
      for (final button in widget.buttons) {
        _controlBarProvider.addEphemeralButton(button);
      }
      _buttonsAdded = true;
    } else if (!shouldShow && _buttonsAdded) {
      // We previously added ephemeral, but we no longer need them
      for (final button in widget.buttons) {
        _controlBarProvider.removeEphemeralButton(button);
      }
      _buttonsAdded = false;
    }
  }

  @override
  void dispose() {
    _navStore.removeListener(_listener);
    // If we had ephemeral buttons added, remove them on dispose
    if (_buttonsAdded) {
      for (final button in widget.buttons) {
        _controlBarProvider.removeEphemeralButton(button);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}