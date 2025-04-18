import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../models/homelife/meal_plan.dart';
import '../../../../../providers/homelife/meal_provider.dart';
import '../../../../../providers/homelife/grocery_list_provider.dart';
import '../../../../nav/providers/navigation_store.dart';

class HomelifeMealsTab extends StatefulWidget {
  const HomelifeMealsTab({Key? key}) : super(key: key);

  @override
  State<HomelifeMealsTab> createState() => _HomelifeMealsTabState();
}

class _HomelifeMealsTabState extends State<HomelifeMealsTab> {
  bool _bootstrapped = false;

  // ───────────────────────────────────────────────── bootstrap
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    final mealsProv   = context.read<MealProvider>();
    final listsProv   = context.read<GroceryListProvider>();

    // initial fetch
    mealsProv.loadMeals();
    listsProv.loadGroceryLists();

    // hook up the global Refresh button
    context.read<NavigationStore>().setRefreshCallback(() async {
      await Future.wait([
        mealsProv.loadMeals(),
        listsProv.loadGroceryLists(),
      ]);
    });
  }

  @override
  void dispose() {
    // remove our refresh callback if we still own it
    final nav = context.read<NavigationStore>();
    if (nav.refreshCallback != null) nav.clearRefreshCallback();
    super.dispose();
  }

  // ───────────────────────────────────────────────── helpers
  Widget _header(String text, IconData icon) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.secondary),
      const SizedBox(width: 8),
      Text(text, style: Theme.of(context).textTheme.headlineSmall),
    ],
  );

  final _dateFmt = DateFormat('EEE, MMM d'); // Mon, Jan 8

  Widget _empty({required String asset, required String msg}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        SvgPicture.asset(asset, height: 120),
        const SizedBox(height: 16),
        Text(msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );

  // ───────────────────────────────────────────────── meal section
  Widget _mealPlans(MealProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.meals.isEmpty) {
      return _empty(
        asset: 'assets/images/empty_plate.svg',
        msg: 'No meals scheduled yet.\nTap ＋ to add one.',
      );
    }

    // group by date (yyyy‑MM‑dd)
    final map = <String, List<MealPlan>>{};
    for (final m in p.meals) {
      map.putIfAbsent(m.date, () => []).add(m);
    }

    final sortedKeys = map.keys.toList()..sort();

    return Column(
      children: sortedKeys.map((key) {
        final list = map[key]!..sort((a, b) => a.mealType.compareTo(b.mealType));
        final date = DateTime.parse(key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dateFmt.format(date),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = list[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(
                        _mealIcon(m.mealType),
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(m.recipeName,
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                        m.mealType.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(letterSpacing: 1.2),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _mealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_twighlight;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.restaurant;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.fastfood;
    }
  }

  // ───────────────────────────────────────────────── grocery section
  Widget _groceryLists(GroceryListProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.groceryLists.isEmpty) {
      return _empty(
        asset: 'assets/images/empty_cart.svg',
        msg: 'Your pantry is empty.\nTap ＋ to create a grocery list.',
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: p.groceryLists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final gl = p.groceryLists[i];
        final purchased =
            gl.items.where((it) => it.purchased).length; // requires items eager‑loaded
        final total = gl.items.length;
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart, size: 30),
            title: Text(gl.name),
            subtitle: total == 0
                ? const Text('No items yet')
                : Text('$purchased of $total purchased'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to grocery‑list detail screen
            },
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────── build
  @override
  Widget build(BuildContext context) {
    final mealsProv = context.watch<MealProvider>();
    final listsProv = context.watch<GroceryListProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          mealsProv.loadMeals(),
          listsProv.loadGroceryLists(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header('Meal plans', Icons.fastfood),
            const SizedBox(height: 12),
            _mealPlans(mealsProv),

            const SizedBox(height: 32),
            _header('Grocery lists', Icons.shopping_cart),
            const SizedBox(height: 12),
            _groceryLists(listsProv),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/* ═════════════════════════════════  models used  ═════════════════════════════
   The code assumes:
     class MealPlan {
       int id;
       String date;          // yyyy‑MM‑dd
       String mealType;      // Breakfast / Lunch / Dinner / Snack / …
       String recipeName;
       String? notes;
     }

     class GroceryList {
       int id;
       String name;
       String? description;
       List<GroceryItem> items;
     }

     class GroceryItem {
       int id;
       String name;
       String? quantity;
       bool purchased;
     }
   as generated by your existing DTOs.
   ════════════════════════════════════════════════════════════════════════════ */