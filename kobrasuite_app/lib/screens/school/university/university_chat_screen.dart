import 'package:flutter/material.dart';
import '../../../widgets/chat/chat_widget.dart';

class UniversityChatScreen extends StatelessWidget {
  final String universityId;

  const UniversityChatScreen({Key? key, required this.universityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here, the discussion thread is for the "UNIVERSITY" context.
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Chat'),
      ),
      body: ChatWidget(
        scopeType: 'UNIVERSITY',
        scopeId: universityId,
      ),
    );
  }
}