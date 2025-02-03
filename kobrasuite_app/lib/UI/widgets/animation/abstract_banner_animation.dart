// File: lib/UI/widgets/abstract_banner_animation.dart
import 'dart:math';

import 'package:flutter/material.dart';

class AbstractBannerAnimation extends StatefulWidget {
  final List<Color> colors;
  const AbstractBannerAnimation({Key? key, required this.colors}) : super(key: key);

  @override
  _AbstractBannerAnimationState createState() => _AbstractBannerAnimationState();
}

class _AbstractBannerAnimationState extends State<AbstractBannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _AbstractBannerPainter(widget.colors, _animation.value),
        );
      },
    );
  }
}

class _AbstractBannerPainter extends CustomPainter {
  final List<Color> colors;
  final double progress;
  _AbstractBannerPainter(this.colors, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2.0;
    // Draw 20 animated lines that grow and shrink using a sine wave.
    int numLines = 20;
    double spacing = size.width / (numLines + 1);
    for (int i = 0; i < numLines; i++) {
      double x = spacing * (i + 1);
      double wave = sin(progress + i * 0.5);
      double lineLength = size.height / 2 * (0.5 + 0.5 * wave);
      Offset start = Offset(x, size.height / 2 - lineLength);
      Offset end = Offset(x, size.height / 2 + lineLength);
      Color lineColor = colors[i % colors.length].withOpacity(0.7);
      paint.color = lineColor;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AbstractBannerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}