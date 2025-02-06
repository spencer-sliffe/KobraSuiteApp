import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_bar_provider.dart';
import 'package:kobrasuite_app/UI/nav/control_bar/control_bar_button.dart';

class PageControlBar extends StatelessWidget {
  const PageControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controlBarProvider = context.watch<ControlBarProvider>();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: controlBarProvider.buttons
            .map((button) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ControlBarButton(
            icon: button.icon,
            label: button.label,
            onPressed: button.onPressed,
          ),
        ))
            .toList(),
      ),
    );
  }
}