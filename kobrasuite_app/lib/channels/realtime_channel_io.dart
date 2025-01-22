// lib/channels/realtime_channel_io.dart

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel getWebSocketChannel(String url, {Map<String, dynamic>? headers}) {
  return IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
}