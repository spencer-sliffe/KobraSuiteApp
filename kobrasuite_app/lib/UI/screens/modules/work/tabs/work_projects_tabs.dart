import 'package:flutter/material.dart';

class WorkProjectsTab extends StatelessWidget {
  const WorkProjectsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example placeholder for a list of projects
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: const [
                Card(child: Center(child: Text('Project: Alpha'))),
                Card(child: Center(child: Text('Project: Bravo'))),
                Card(child: Center(child: Text('Project: Charlie'))),
                Card(child: Center(child: Text('Project: Delta'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}