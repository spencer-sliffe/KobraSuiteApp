import 'package:flutter/material.dart';

class WorkTeamsTab extends StatelessWidget {
  const WorkTeamsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example placeholder for a list of teams
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Card(child: ListTile(title: Text('Team A'))),
                Card(child: ListTile(title: Text('Team B'))),
                Card(child: ListTile(title: Text('Team C'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}