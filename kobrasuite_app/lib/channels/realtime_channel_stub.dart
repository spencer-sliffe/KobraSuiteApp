// lib/channels/realtime_channel_stub.dart

import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel getWebSocketChannel(String url, {Map<String, dynamic>? headers}) {
  throw UnsupportedError('WebSocket channels are not supported on this platform.');
}