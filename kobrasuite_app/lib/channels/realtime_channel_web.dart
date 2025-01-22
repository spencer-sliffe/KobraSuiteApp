// lib/channels/realtime_channel_web.dart

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel getWebSocketChannel(String url, {Map<String, dynamic>? headers}) {
  return HtmlWebSocketChannel.connect(url);
}