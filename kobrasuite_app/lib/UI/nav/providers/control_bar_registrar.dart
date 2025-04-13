import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'control_bar_provider.dart';
import 'navigation_store.dart';

class ControlBarRegistrar extends StatefulWidget {
  final List<ControlBarButtonModel> buttons;
  final Widget child;
  final int? financeTabIndex;
  final int? workTabIndex;
  final int? homelifeTabIndex;
  final int? schoolTabIndex;
  final VoidCallback? refreshCallback;

  const ControlBarRegistrar({
    super.key,
    required this.buttons,
    required this.child,
    this.financeTabIndex,
    this.schoolTabIndex,
    this.workTabIndex,
    this.homelifeTabIndex,
    this.refreshCallback,
  });

  @override
  State<ControlBarRegistrar> createState() => _ControlBarRegistrarState();
}

class _ControlBarRegistrarState extends State<ControlBarRegistrar> {
  final Set<String> _registeredButtonIds = {};
  late NavigationStore _navStore;
  late ControlBarProvider _controlBarProvider;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _navStore = context.read<NavigationStore>();
    _controlBarProvider = context.read<ControlBarProvider>();
    _listener = _updateButtons;
    _navStore.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtons());
  }

  @override
  void didUpdateWidget(covariant ControlBarRegistrar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger an update when the widget is updated so that tab 0 buttons are added
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
    if (shouldShow) {
      if (widget.refreshCallback != null) {
        _navStore.setRefreshCallback(widget.refreshCallback!);
      }
      for (final button in widget.buttons) {
        if (!_registeredButtonIds.contains(button.id)) {
          _controlBarProvider.addEphemeralButton(button);
          _registeredButtonIds.add(button.id);
        }
      }
    } else {
      if (widget.refreshCallback != null &&
          _navStore.refreshCallback == widget.refreshCallback) {
        _navStore.clearRefreshCallback();
      }
      for (final button in widget.buttons) {
        if (_registeredButtonIds.contains(button.id)) {
          _controlBarProvider.removeEphemeralButton(button);
          _registeredButtonIds.remove(button.id);
        }
      }
    }
  }

  @override
  void dispose() {
    _navStore.removeListener(_listener);
    for (final button in widget.buttons) {
      if (_registeredButtonIds.contains(button.id)) {
        _controlBarProvider.removeEphemeralButton(button);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}