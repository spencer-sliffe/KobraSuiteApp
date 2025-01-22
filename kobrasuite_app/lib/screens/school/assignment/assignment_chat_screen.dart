import 'package:flutter/material.dart';
import '../../../widgets/chat/chat_widget.dart';

class AssignmentChatScreen extends StatelessWidget {
  final String assignmentId;

  const AssignmentChatScreen({Key? key, required this.assignmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here, the discussion thread is for the "ASSIGNMENT" context.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Chat'),
      ),
      body: ChatWidget(
        scopeType: 'ASSIGNMENT',
        scopeId: assignmentId,
      ),
    );
  }
}