import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/websocket_service.dart' show ConnectionStatus;
import 'connection_provider.dart';
import 'sdk_server_service_provider.dart';

part 'models_provider.g.dart';

const _kFallbackModels = [
  'claude-opus-4.6',
  'claude-sonnet-4.6',
  'claude-haiku-4.5',
  'gpt-4o',
  'gpt-4.1',
];

/// Fetches available model IDs from the Copilot SDK via the server.
/// Re-fetches automatically whenever the WS connection state changes.
/// Falls back to a static list when the server is unreachable.
@riverpod
Future<List<String>> availableModels(Ref ref) async {
  final connStatus = ref.watch(connectionProvider);
  if (connStatus != ConnectionStatus.connected) return _kFallbackModels;

  final service = ref.watch(sdkServerServiceProvider);
  try {
    final models = await service.fetchModels();
    if (models.isNotEmpty) return models;
  } catch (_) {
    // fall through to defaults
  }
  return _kFallbackModels;
}
