import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_bar_provider.dart';

class ControlBarRegistrar extends StatefulWidget {
  final List<ControlBarButtonModel> buttons;
  final Widget child;

  const ControlBarRegistrar({
    Key? key,
    required this.buttons,
    required this.child,
  }) : super(key: key);

  @override
  State<ControlBarRegistrar> createState() => _ControlBarRegistrarState();
}

class _ControlBarRegistrarState extends State<ControlBarRegistrar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ControlBarProvider>();
      for (var b in widget.buttons) {
        provider.addEphemeralButton(b);
      }
    });
  }

  @override
  void dispose() {
    final provider = context.read<ControlBarProvider>();
    for (var b in widget.buttons) {
      provider.removeEphemeralButton(b);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}