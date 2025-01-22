// lib/services/school/realtime_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../channels/realtime_channel_io.dart';
import '../../models/school/discussion_thread.dart'; // Ensure you have this model
import '../../models/school/discussion_post.dart';  // Added import for DiscussionPost
import '../general/auth_service.dart';
import '../school/discussion_service.dart';

class RealtimeService extends ChangeNotifier {
  final Dio _dio;
  final DiscussionService _discussionService;
  final AuthService _authService;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _scopeType;
  String? _scopeId;
  final List<Map<String, dynamic>> _messages = [];
  bool _connected = false;
  bool _manualDisconnect = false;
  final Duration _heartbeatInterval = const Duration(seconds: 10);
  final Duration _reconnectInterval = const Duration(seconds: 5);

  // Exposed getters
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);
  bool get connected => _connected;

  // Constructor with dependency injection
  RealtimeService(this._dio, this._discussionService, this._authService);

  /// Establishes a WebSocket connection based on [scopeType] and [scopeId].
  Future<void> connect(String scopeType, String scopeId) async {
    _manualDisconnect = false;
    _scopeType = scopeType;
    _scopeId = scopeId;
    final wsUrl = _buildWsUrl(scopeType, scopeId);
    try {
      _channel = getWebSocketChannel(wsUrl, headers: _headers());
      _connected = true;
      notifyListeners();
      _startHeartbeat();
      _channel?.stream.listen(
            (event) {
          _handleIncoming(event);
        },
        onDone: () {
          _connected = false;
          notifyListeners();
          _attemptReconnect();
        },
        onError: (error) {
          _connected = false;
          notifyListeners();
          _attemptReconnect();
        },
      );
    } catch (e) {
      _connected = false;
      notifyListeners();
      _attemptReconnect();
    }
  }

  /// Fetches the chat history based on [scopeType] and [scopeId].
  Future<void> fetchHistory(String scopeType, String scopeId) async {
    _messages.clear();
    final userId = _authService.loggedInUserId;
    if (userId == null) return;

    try {
      // Retrieve discussion threads
      final List<DiscussionThread> threads = await _discussionService.getDiscussionThreads(
        scope: scopeType,
        scopeId: scopeId,
      );

      if (threads.isNotEmpty) {
        final int threadId = threads.first.id; // Correct property access

        // Retrieve posts for the first thread
        final List<DiscussionPost> posts = await _discussionService.getDiscussionPosts(threadId);

        for (final post in posts) {
          final int authorId = post.authorId; // Correct property access
          final String content = post.content; // Correct property access
          final String createdAt = post.createdAt.toIso8601String(); // Convert DateTime to String

          _messages.add({
            'type': 'message',
            'user': authorId == userId ? 'me' : 'other',
            'content': content,
            'timestamp': createdAt,
          });
        }
        notifyListeners();
      }
    } catch (e) {
      // Handle errors appropriately
      debugPrint('Failed to fetch chat history: $e');
      // Optionally, you can add an error message to _messages or set an error state
    }
  }

  /// Builds the WebSocket URL based on [scopeType] and [scopeId].
  String _buildWsUrl(String scopeType, String scopeId) {
    final base = _authService.baseUrl.replaceAll('http', 'ws');
    final url = '$base/ws/school-chat/$scopeType/$scopeId/';
    final token = _accessToken;
    if (kIsWeb && token != null) {
      return '$url?token=$token';
    }
    return url;
  }

  /// Retrieves the current access token.
  String? get _accessToken => _authService.accessToken;

  /// Constructs the headers for the WebSocket connection.
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  /// Sends a message through the WebSocket connection.
  void sendMessage(String content) {
    if (_channel == null || !_connected) return;
    final authorId = _authService.loggedInUserId;
    if (authorId == null) return;

    final message = {
      'type': 'message',
      'payload': {
        'author_id': authorId,
        'content': content,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
    _channel?.sink.add(jsonEncode(message));
    _messages.add({
      'type': 'message',
      'payload': {
        'author_id': authorId,
        'content': content,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'user': 'me',
      'content': content,
    });
    notifyListeners();
  }

  /// Handles incoming messages from the WebSocket connection.
  void _handleIncoming(dynamic event) {
    try {
      final String data = event.toString();
      final Map<String, dynamic> msgMap = jsonDecode(data);
      _messages.add(msgMap);
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing incoming message: $e');
      // Optionally, handle the error by adding an error message to _messages
    }
  }

  /// Starts the heartbeat mechanism to keep the WebSocket connection alive.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_connected) {
        final ping = jsonEncode({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
        _channel?.sink.add(ping);
      }
    });
  }

  /// Attempts to reconnect the WebSocket connection upon disconnection.
  void _attemptReconnect() {
    if (_manualDisconnect) return;
    _heartbeatTimer?.cancel();
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _reconnectTimer = Timer.periodic(_reconnectInterval, (timer) {
      if (!_connected && _scopeType != null && _scopeId != null) {
        connect(_scopeType!, _scopeId!);
      } else {
        _reconnectTimer?.cancel();
      }
    });
  }

  /// Disconnects the WebSocket connection manually.
  void disconnect() {
    _manualDisconnect = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _connected = false;
    notifyListeners();
  }
}