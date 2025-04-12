import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_bar_provider.dart';
import 'control_bar_button.dart';

class PageControlBar extends StatelessWidget {
  const PageControlBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controlBarProvider = context.watch<ControlBarProvider>();
    final buttons = controlBarProvider.allButtons;

    return Container(
      // Use the same gray color as your theme’s surface or another neutral tone
      color: Theme.of(context).colorScheme.surface,
      // A SafeArea ensures the bar isn’t cut off by device edges or nav gestures
      child: SafeArea(
        // If you also want to remove top or bottom padding from SafeArea, set these to false
        top: false,
        bottom: false,
        // Minimal horizontal/vertical padding so items aren’t pressed against the screen edge
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // You can stick with a Wrap or Row depending on how many buttons you’ll have
          child: Row(
            children: buttons.map((button) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ControlBarButton(
                  icon: button.icon,
                  label: button.label,
                  onPressed: button.onPressed,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}