/* File: lib/UI/widgets/abstract_banner_animation.dart */
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
        // Animate the gradient's alignment based on the animation value.
        return Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _animation.value, -1),
              end: Alignment(1 - 2 * _animation.value, 1),
              colors: widget.colors,
            ),
          ),
        );
      },
    );
  }
}