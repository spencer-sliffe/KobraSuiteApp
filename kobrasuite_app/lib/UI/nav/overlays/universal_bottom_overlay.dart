import 'package:flutter/material.dart';

class UniversalBottomOverlay extends StatelessWidget {
  final Widget child;
  const UniversalBottomOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The available height is constraints.maxHeight.
          return Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 12,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // The overlay will take up all available height.
                  maxHeight: constraints.maxHeight,
                ),
                child: SafeArea(
                  top: false, // We want it to fill from the top of the body.
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}