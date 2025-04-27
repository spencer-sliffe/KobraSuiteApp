import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_bar_provider.dart';
import 'control_bar_button.dart';

class PageControlBar extends StatelessWidget {
  const PageControlBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttons = context.watch<ControlBarProvider>().allButtons;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // horizontal scroll view 
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: buttons.map((b) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ControlBarButton(
                  icon: b.icon,
                  label: b.label,
                  onPressed: b.onPressed,
                ),
              )).toList(),
            ),
          ),
          // ----------------------------------------------------------------
        ),
      ),
    );
  }
}