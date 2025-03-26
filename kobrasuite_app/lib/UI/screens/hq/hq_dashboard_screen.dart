import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nav/providers/navigation_store.dart';
import '../../widgets/cards/module_card.dart';

class HQDashboardScreen extends StatefulWidget {
  const HQDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HQDashboardScreen> createState() => _HQDashboardScreenState();
}

class _HQDashboardScreenState extends State<HQDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  double bubbleSize = 80;

  final modulesData = [
    {
      'name': 'Homelife',
      'level': 1,
      'population': 25,
      'streak': 3,
      'experience': 120,
      'currency': 100
    },
    {
      'name': 'Finance',
      'level': 2,
      'population': 200,
      'streak': 7,
      'experience': 840,
      'currency': 220
    },
    {
      'name': 'Work',
      'level': 3,
      'population': 380,
      'streak': 15,
      'experience': 1800,
      'currency': 450
    },
    {
      'name': 'School',
      'level': 2,
      'population': 180,
      'streak': 7,
      'experience': 1800,
      'currency': 450
    },
  ];

  @override
  void initState() {
    super.initState();
    controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
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
            angle: animation.value * pi,
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

  Widget xpNotification() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * animation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              'XP +12',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }

  Widget quickStatsCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget overviewCard({
    required String title,
    required Widget content,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget budgetsOverviewCard() {
    return overviewCard(
      title: 'Budgets',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '3 Active, 1 Over',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.7,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionsOverviewCard() {
    return overviewCard(
      title: 'Transactions',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recent: 12, Total: 265',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+ \$210 today',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget stocksOverviewCard() {
    return overviewCard(
      title: 'Stocks',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '4 Positions',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget watchlistOverviewCard() {
    return overviewCard(
      title: 'Watchlist',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '7 Items',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '2% up overall',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget analysisOverviewCard() {
    return overviewCard(
      title: 'Analysis',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Trend: Positive',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Last 30 Days Up 6%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget newsOverviewCard() {
    return overviewCard(
      title: 'News',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '3 Unread Articles',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Market Rally Continues...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationsCard() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
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

  Widget calendarOverviewCard() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
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

  Widget achievements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 24),
        const SizedBox(width: 8),
        Icon(Icons.workspace_premium, color: Colors.orangeAccent, size: 24),
        const SizedBox(width: 8),
        Icon(Icons.military_tech, color: Colors.blueAccent, size: 24),
      ],
    );
  }

  Widget multipliers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.trending_up, color: Colors.redAccent, size: 24),
        const SizedBox(width: 16),
        Icon(Icons.trending_up, color: Colors.greenAccent, size: 24),
      ],
    );
  }

  Widget profileSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Wallet: \$2,350',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          achievements(),
          const SizedBox(height: 12),
          multipliers(),
        ],
      ),
    );
  }

  Widget modulesGrid() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Modules',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modulesData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) {
              return ModuleCard(data: modulesData[index]);
            },
          ),
        ],
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
          // Background gradient + floating bubbles
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF141E30), Color(0xFF243B55)],
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),
                  xpNotification(),
                  const SizedBox(height: 20),

                  // Wrap everything in one layout so it lines up nicely
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Quick stats
                      quickStatsCard(title: 'Net Worth', value: '\$18,900'),
                      quickStatsCard(title: 'Monthly Gain', value: '\$1,450'),

                      budgetsOverviewCard(),
                      transactionsOverviewCard(),
                      stocksOverviewCard(),
                      watchlistOverviewCard(),
                      analysisOverviewCard(),
                      newsOverviewCard(),
                      notificationsCard(),
                      calendarOverviewCard(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  profileSummary(),
                  const SizedBox(height: 20),
                  modulesGrid(),
                  const SizedBox(height: 24),
                  if (isDashboard)
                    Center(
                      child: Text(
                        'Swipe Up/Down or Pinch to switch.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white54),
                      ),
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