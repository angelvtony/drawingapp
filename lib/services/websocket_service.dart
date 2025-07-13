import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:8080"), // Replace with actual WebSocket URL
  );

  Stream<dynamic> get stream => _channel.stream;

  void sendDrawing(Map<String, dynamic> data) {
    _channel.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel.sink.close();
  }
}
