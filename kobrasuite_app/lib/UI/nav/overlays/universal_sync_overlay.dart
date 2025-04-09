import 'package:flutter/material.dart';

class UniversalSyncOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final Duration duration;
  final IconData icon;

  const UniversalSyncOverlay({
    Key? key,
    required this.title,
    required this.subtitle,
    this.duration = const Duration(seconds: 2),
    this.icon = Icons.sync,
  }) : super(key: key);

  @override
  _UniversalSyncOverlayState createState() => _UniversalSyncOverlayState();
}

class _UniversalSyncOverlayState extends State<UniversalSyncOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Setup the controller with the provided duration
    _rotationController =
    AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        // Full-screen semi-transparent dark background with a gradient.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.black.withOpacity(0.65),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotating icon animation.
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.1415926535897932,
                    child: child,
                  );
                },
                child: Icon(
                  widget.icon,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Title text.
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle text.
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}