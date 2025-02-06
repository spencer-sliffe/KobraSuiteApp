import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_bar_provider.dart';

class ControlBarRegistrar extends StatefulWidget {
  final List<ControlBarButtonModel> buttons;
  final Widget child;

  const ControlBarRegistrar({Key? key, required this.buttons, required this.child}) : super(key: key);

  @override
  State<ControlBarRegistrar> createState() => _ControlBarRegistrarState();
}

class _ControlBarRegistrarState extends State<ControlBarRegistrar> {
  late final ControlBarProvider _controlBarProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controlBarProvider = context.read<ControlBarProvider>();
      for (var button in widget.buttons) {
        _controlBarProvider.addButton(button);
      }
    });
  }

  @override
  void dispose() {
    for (var button in widget.buttons) {
      _controlBarProvider.removeButton(button);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}