import 'package:flutter/material.dart';

class HomelifeScreen extends StatelessWidget {
  const HomelifeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder UI: chores or events
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Homelife Module',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Center(
                    child: Text('Chores'),
                  ),
                ),
                Card(
                  child: Center(
                    child: Text('Shared Calendar'),
                  ),
                ),
                Card(
                  child: Center(
                    child: Text('Meal Plans'),
                  ),
                ),
                Card(
                  child: Center(
                    child: Text('Grocery List'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}