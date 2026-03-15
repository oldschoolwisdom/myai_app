import 'dart:io';
import 'package:dio/dio.dart';

class ServerBinaryNotFoundException implements Exception {
  final String path;
  ServerBinaryNotFoundException(this.path);

  @override
  String toString() => 'Server binary not found at: $path';
}

class ServerProcessService {
  Process? _process;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start({required String binaryPath}) async {
    // First check: is a server already running?
    if (await _isAlreadyRunning()) {
      _running = true;
      return;
    }

    final file = File(binaryPath);
    if (!await file.exists()) {
      throw ServerBinaryNotFoundException(binaryPath);
    }

    // Start the Go server binary. It always listens on localhost:7788.
    _process = await Process.start(binaryPath, []);
    _running = true;

    // Pipe server stderr to our stderr for debugging.
    _process!.stderr.listen((data) => stderr.add(data));

    // Poll until server is ready (up to 5 seconds).
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:7788',
      connectTimeout: const Duration(milliseconds: 500),
      receiveTimeout: const Duration(milliseconds: 500),
    ));

    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await dio.get('/auth/status');
        return; // ready
      } catch (_) {}
    }
    // If we reach here the process started but didn't respond — still continue.
  }

  Future<void> stop() async {
    _process?.kill();
    await _process?.exitCode;
    _process = null;
    _running = false;
  }

  /// Returns true if a server is already listening on localhost:7788.
  Future<bool> _isAlreadyRunning() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:7788',
        connectTimeout: const Duration(milliseconds: 300),
        receiveTimeout: const Duration(milliseconds: 300),
      ));
      await dio.get('/auth/status');
      return true;
    } catch (_) {
      return false;
    }
  }
}
