// services/websocket_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:get/get.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  final String url;
  final RxBool isConnected = false.obs;

  WebSocketService({required this.url});

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      isConnected.value = true;
      print('WebSocket connected to: $url');
    } catch (e) {
      isConnected.value = false;
      print('WebSocket connection error: $e');
    }
  }

  Stream<dynamic>? get stream => _channel?.stream;

  void disconnect() {
    _channel?.sink.close();
    isConnected.value = false;
    print('WebSocket disconnected');
  }

  void sendMessage(String message) {
    if (_channel != null && isConnected.isTrue) {
      _channel?.sink.add(message);
    } else {
      print('WebSocket not connected. Cannot send message.');
    }
  }
}