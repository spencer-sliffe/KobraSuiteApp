import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/general/auth_service.dart';
import '../../../services/service_locator.dart';

class DraggableChatOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const DraggableChatOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  DraggableChatOverlayState createState() => DraggableChatOverlayState();
}

class DraggableChatOverlayState extends State<DraggableChatOverlay> {
  Offset position = const Offset(100, 100);
  double width = 300;
  double height = 400;
  bool resizing = false;
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchConversation();
  }

  Future<void> fetchConversation() async {
    final auth = serviceLocator<AuthService>();
    final token = auth.accessToken;
    final baseUrl = auth.baseUrl;
    if (baseUrl.isEmpty || token == null) return;

    final url = Uri.parse('$baseUrl/api/chatbot/conversation/');
    try {
      final response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        messages.clear();
        for (final item in data) {
          final userText = item['user_message'] ?? '';
          final botText = item['bot_response'] ?? '';
          messages.add({'sender': 'user', 'text': userText});
          messages.add({'sender': 'bot', 'text': botText});
        }
        setState(() {});
      }
    } catch (_) {
      // Log or handle error
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    messages.add({'sender': 'user', 'text': content});
    setState(() => loading = true);

    final auth = serviceLocator<AuthService>();
    final token = auth.accessToken;
    final baseUrl = auth.baseUrl;
    if (baseUrl.isEmpty || token == null) {
      setState(() => loading = false);
      return;
    }

    final url = Uri.parse('$baseUrl/api/chatbot/chat/');
    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({'message': content}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final botResponse = data['response'] ?? '';
        messages.add({'sender': 'bot', 'text': botResponse});
      }
    } catch (_) {
      // Log or handle error
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: width,
      height: height,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!resizing) {
            setState(() => position += details.delta);
          } else {
            setState(() {
              width += details.delta.dx;
              height += details.delta.dy;
              if (width < 250) width = 250;
              if (height < 200) height = 200;
            });
          }
        },
        onTapDown: (_) => resizing = false,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Assistant',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTapDown: (_) => resizing = true,
                      child: const Icon(Icons.open_with, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['sender'] == 'user';
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            constraints: BoxConstraints(maxWidth: width * 0.75),
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
                    if (loading)
                      Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (val) {
                        sendMessage(val);
                        controller.clear();
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
                      final text = controller.text.trim();
                      controller.clear();
                      sendMessage(text);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}