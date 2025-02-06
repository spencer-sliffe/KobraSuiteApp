import 'package:flutter/material.dart';

class ChatOverlay extends StatelessWidget {
  const ChatOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('University Chat', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('Welcome to the University Chat!')),
                ListTile(title: Text('User1: This university is amazing!')),
                ListTile(title: Text('User2: I agree, the campus is beautiful.')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}