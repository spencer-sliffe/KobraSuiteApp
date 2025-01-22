import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/general/realtime_service.dart';
import 'message_bubble.dart';
import 'message_input.dart';

class ChatWidget extends StatefulWidget {
  final String scopeType;
  final String scopeId;

  const ChatWidget({
    Key? key,
    required this.scopeType,
    required this.scopeId,
  }) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  late RealtimeService _realtimeService;
  bool _showScrollButton = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _realtimeService = Provider.of<RealtimeService>(context, listen: false);
    _initializeChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeChat() async {
    // Here, fetching history means retrieving discussion posts
    // associated with the discussion thread (i.e. scopeType and scopeId).
    await _realtimeService.fetchHistory(widget.scopeType, widget.scopeId);
    await _realtimeService.connect(widget.scopeType, widget.scopeId);
    _realtimeService.addListener(_onMessagesUpdated);
    _scrollToBottom();
  }

  void _onMessagesUpdated() {
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    final shouldShow = position.pixels < position.maxScrollExtent - 200;
    if (shouldShow != _showScrollButton) {
      setState(() {
        _showScrollButton = shouldShow;
      });
    }
    // Placeholder for pagination/infinite scrolling:
    if (position.pixels <= position.minScrollExtent + 50 && !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    setState(() {
      _isLoadingMore = true;
    });
    // Simulate network delay; in a real app, fetch older discussion posts here.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _sendMessage(String messageText) {
    _realtimeService.sendMessage(messageText);
  }

  @override
  void dispose() {
    _realtimeService.removeListener(_onMessagesUpdated);
    _realtimeService.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the shared RealtimeService for discussion posts (messages).
    final realtime = Provider.of<RealtimeService>(context);
    final messages = realtime.messages.where((m) => m['type'] == 'message').toList();

    return Column(
      children: [
        if (!realtime.connected)
          Container(
            width: double.infinity,
            color: Colors.orangeAccent,
            padding: EdgeInsets.all(8.h),
            child: const Text(
              'Connecting...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg['user'] == 'me';
              final content = msg['content'] ?? msg['payload']?['content'] ?? '';
              final timestamp = msg['timestamp'] ?? '';
              return MessageBubble(
                content: content,
                timestamp: timestamp,
                isOwnMessage: isMe,
              );
            },
          ),
        ),
        if (_showScrollButton)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Semantics(
              button: true,
              label: 'Scroll to bottom',
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToBottom,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
          ),
        MessageInput(
          onSend: _sendMessage,
        ),
      ],
    );
  }
}