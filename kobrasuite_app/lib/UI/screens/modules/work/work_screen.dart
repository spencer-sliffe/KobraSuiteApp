import 'package:flutter/material.dart';

class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: tasks, projects, teams
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Center(
                    child: Text('Project A'),
                  ),
                ),
                Card(
                  child: Center(
                    child: Text('Team 1'),
                  ),
                ),
                Card(
                  child: Center(
                    child: Text('Work Tasks'),
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