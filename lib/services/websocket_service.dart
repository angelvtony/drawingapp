import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  late Stream _stream;

  WebSocketService() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://your-websocket-url.com'),);
    _stream = _channel.stream.asBroadcastStream();
  }

  Stream get stream => _stream;

  void sendDrawing(Map<String, dynamic> data) {
    _channel.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel.sink.close();
  }
}