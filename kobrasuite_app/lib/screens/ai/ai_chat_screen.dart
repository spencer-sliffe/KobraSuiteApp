import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kobrasuite_app/services/service_locator.dart';
import 'package:kobrasuite_app/services/general/auth_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  AiChatScreenState createState() => AiChatScreenState();
}

class AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchConversation();
  }

  Future<void> _fetchConversation() async {
    final auth = serviceLocator<AuthService>();
    final token = auth.accessToken;
    final baseUrl = auth.baseUrl;

    if (baseUrl.isEmpty || token == null) return;

    final url = Uri.parse('$baseUrl/api/chatbot/conversation/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> fetched = data.map((item) {
          return {
            'sender': item['user'] != null ? 'user' : 'assistant',
            'userText': item['user_message'] ?? '',
            'botText': item['bot_response'] ?? '',
          };
        }).toList();

        setState(() {
          _messages.clear();
          for (final msg in fetched) {
            _messages.add({'sender': 'user', 'text': msg['userText']});
            _messages.add({'sender': 'bot', 'text': msg['botText']});
          }
        });
      }
    } catch (_) {
      // Optionally log or handle error
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': content});
      _loading = true;
    });

    final auth = serviceLocator<AuthService>();
    final token = auth.accessToken;
    final baseUrl = auth.baseUrl;

    if (baseUrl.isEmpty || token == null) {
      setState(() => _loading = false);
      return;
    }

    final url = Uri.parse('$baseUrl/api/chatbot/chat/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'message': content}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final botResponse = data['response'] ?? '';
        setState(() {
          _messages.add({'sender': 'bot', 'text': botResponse});
        });
      }
    } catch (_) {
      // Optionally log or handle error
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (val) {
                    _sendMessage(val);
                    _controller.clear();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = _controller.text.trim();
                  _controller.clear();
                  _sendMessage(text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}