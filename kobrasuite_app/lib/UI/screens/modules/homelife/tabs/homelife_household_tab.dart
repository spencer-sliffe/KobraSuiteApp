import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/homelife/household.dart';
import '../../../../../providers/homelife/household_provider.dart';


class HomelifeHouseholdTab extends StatefulWidget {
  const HomelifeHouseholdTab({Key? key}) : super(key: key);

  @override
  State<HomelifeHouseholdTab> createState() => _HomelifeHouseholdTabState();
}

class _HomelifeHouseholdTabState extends State<HomelifeHouseholdTab> {
  @override
  void initState() {
    super.initState();
    // Load the household when this tab appears
    Future.microtask(
          () => context.read<HouseholdProvider>().loadHousehold(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HouseholdProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.household != null) {
      final Household household = provider.household!;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              household.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text('Type: ${household.householdType}'),
          ),
        ),
      );
    }

    // No household exists
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No household found.\n'
              'Tap the + button to add a household and enable HomeLife features.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}