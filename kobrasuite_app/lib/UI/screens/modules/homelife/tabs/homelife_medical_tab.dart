import 'package:flutter/material.dart';

class HomelifeMedicalTab extends StatelessWidget {
  const HomelifeMedicalTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example placeholder for a household grocery list
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
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