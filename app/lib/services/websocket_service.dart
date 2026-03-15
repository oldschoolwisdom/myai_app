import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ws_event.dart';

export 'package:flutter/foundation.dart' show ValueNotifier;

enum ConnectionStatus { disconnected, connecting, connected, error }

class WebSocketService {
  WebSocketService({required int port}) : _port = port;

  final int _port;
  WebSocketChannel? _channel;
  final StreamController<WsEvent> _controller =
      StreamController<WsEvent>.broadcast();
  final _statusNotifier = ValueNotifier(ConnectionStatus.disconnected);

  int _retryCount = 0;
  static const int _maxRetries = 5;
  bool _disposed = false;

  Stream<WsEvent> get events => _controller.stream;
  ValueNotifier<ConnectionStatus> get status => _statusNotifier;

  Future<void> connect() async {
    if (_disposed) return;
    _statusNotifier.value = ConnectionStatus.connecting;
    try {
      final uri = Uri.parse('ws://localhost:$_port/ws');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _statusNotifier.value = ConnectionStatus.connected;
      _retryCount = 0;
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _controller.add(WsEvent.fromJson(json));
          } catch (_) {}
        },
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
      );
    } catch (_) {
      _onDisconnect();
    }
  }

  void _onDisconnect() {
    if (_disposed) return;
    _statusNotifier.value = ConnectionStatus.disconnected;
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(const Duration(seconds: 2), connect);
    } else {
      _statusNotifier.value = ConnectionStatus.error;
    }
  }

  void disconnect() {
    _disposed = true;
    _channel?.sink.close();
    _statusNotifier.value = ConnectionStatus.disconnected;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
