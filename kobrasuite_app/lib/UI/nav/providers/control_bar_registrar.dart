// lib/UI/nav/widgets/control_bar_registrar.dart
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
    Key? key,
    required this.buttons,
    required this.child,
    this.financeTabIndex,
    this.schoolTabIndex,
    this.workTabIndex,
    this.homelifeTabIndex
  }) : super(key: key);

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
    _navStore.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateButtons());
  }

  void _updateButtons() {
    bool shouldShow = false;
    if (widget.schoolTabIndex != null) {
      shouldShow = (_navStore.activeModule == Module.School &&
          _navStore.activeSchoolTabIndex == widget.schoolTabIndex);
    }
    if (widget.homelifeTabIndex != null) {
      shouldShow = (_navStore.activeModule == Module.HomeLife &&
          _navStore.activeHomeLifeTabIndex == widget.homelifeTabIndex);
    }
    if (widget.workTabIndex != null) {
      shouldShow = (_navStore.activeModule == Module.Work &&
          _navStore.activeWorkTabIndex == widget.workTabIndex);
    }
    if (widget.financeTabIndex != null) {
      shouldShow = (_navStore.activeModule == Module.Finances &&
          _navStore.activeFinancesTabIndex == widget.financeTabIndex);
    }

    if (shouldShow && !_buttonsAdded) {
      for (var button in widget.buttons) {
        _controlBarProvider.addEphemeralButton(button);
      }
      _buttonsAdded = true;
    } else if (!shouldShow && _buttonsAdded) {
      for (var button in widget.buttons) {
        _controlBarProvider.removeEphemeralButton(button);
      }
      _buttonsAdded = false;
    }
  }

  @override
  void dispose() {
    _navStore.removeListener(_listener);
    if (_buttonsAdded) {
      for (var button in widget.buttons) {
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