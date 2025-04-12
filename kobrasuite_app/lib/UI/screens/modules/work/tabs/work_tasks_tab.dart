import 'package:flutter/material.dart';

class WorkTasksTab extends StatelessWidget {
  const WorkTasksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example placeholder for tasks
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Card(child: ListTile(title: Text('Task #1'))),
                Card(child: ListTile(title: Text('Task #2'))),
                Card(child: ListTile(title: Text('Task #3'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}