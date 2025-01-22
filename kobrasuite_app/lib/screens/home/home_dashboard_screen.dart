import 'package:flutter/material.dart';
import '../../widgets/cards/kobra_dashboard_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onModuleSelected;
  const HomeDashboardScreen({Key? key, required this.onModuleSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'KobraSuite Modules',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KobraDashboardCard(
                icon: Icons.account_balance_wallet,
                title: 'Finances',
                subtitle: 'Manage budgets, transactions, bills',
                onTap: () => onModuleSelected(1),
              ),
              KobraDashboardCard(
                icon: Icons.home,
                title: 'Homelife',
                subtitle: 'Chores, events, grocery list',
                onTap: () => onModuleSelected(2),
              ),
              KobraDashboardCard(
                icon: Icons.trending_up,
                title: 'Investing',
                subtitle: 'Portfolios, assets, trades',
                onTap: () => onModuleSelected(3),
              ),
              KobraDashboardCard(
                icon: Icons.school,
                title: 'School',
                subtitle: 'Courses, assignments, study groups',
                onTap: () => onModuleSelected(4),
              ),
              KobraDashboardCard(
                icon: Icons.work,
                title: 'Work',
                subtitle: 'Projects, tasks, teams',
                onTap: () => onModuleSelected(5),
              ),
              KobraDashboardCard(
                icon: Icons.notifications_active,
                title: 'Notifications',
                subtitle: 'Manage alerts, preferences',
                onTap: () => onModuleSelected(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}