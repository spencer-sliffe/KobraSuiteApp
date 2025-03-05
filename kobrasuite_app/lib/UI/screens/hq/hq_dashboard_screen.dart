import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nav/providers/navigation_store.dart';

class HQDashboardScreen extends StatefulWidget {
  const HQDashboardScreen({super.key});

  @override
  HQDashboardScreenState createState() => HQDashboardScreenState();
}

class HQDashboardScreenState extends State<HQDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  double bubbleSize = 80;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget bubble(Color color, double radius, double factor) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * factor -
              animation.value * 90,
          right: animation.value * 100 * factor,
          child: Transform.rotate(
            angle: animation.value * 3.14,
            child: Container(
              width: radius,
              height: radius,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget gamificationWidget() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * animation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'XP +12',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget achievementsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 30),
        const SizedBox(width: 14),
        Icon(Icons.workspace_premium, color: Colors.orangeAccent, size: 30),
        const SizedBox(width: 14),
        Icon(Icons.military_tech, color: Colors.blueAccent, size: 30),
        const SizedBox(width: 14),
        Icon(Icons.local_police, color: Colors.purpleAccent, size: 30),
      ],
    );
  }

  Widget multiplierRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.trending_up, color: Colors.redAccent, size: 34),
        const SizedBox(width: 12),
        Icon(Icons.trending_up, color: Colors.greenAccent, size: 34),
      ],
    );
  }

  Widget notificationsBox() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '3 Notifications',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  Widget calendarBox() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Upcoming Events: 2',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NavigationStore>();
    final isDashboard = store.hqView == HQView.Dashboard;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF141E30),
                  Color(0xFF243B55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bubble(Colors.cyanAccent, bubbleSize, 0.3),
          bubble(Colors.purpleAccent, bubbleSize * 1.3, 0.6),
          bubble(Colors.white, bubbleSize * 0.7, 0.8),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'HQ Dashboard',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aggregated User Profile',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  gamificationWidget(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Wallet: \$2,350',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        achievementsRow(),
                        const SizedBox(height: 16),
                        multiplierRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  notificationsBox(),
                  const SizedBox(height: 16),
                  calendarBox(),
                  const SizedBox(height: 16),
                  if (isDashboard)
                    Text(
                      'Swipe Up/Down or Pinch to switch.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}