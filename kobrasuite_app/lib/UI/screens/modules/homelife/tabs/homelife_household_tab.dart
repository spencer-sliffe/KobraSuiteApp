import 'package:flutter/material.dart';

class HomelifeHouseholdTab extends StatelessWidget {
  const HomelifeHouseholdTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example placeholder for a household grocery list
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Card(child: ListTile(title: Text('TEST'))),
                Card(child: ListTile(title: Text('TEST'))),
                Card(child: ListTile(title: Text('TEST'))),
                Card(child: ListTile(title: Text('TEST'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}