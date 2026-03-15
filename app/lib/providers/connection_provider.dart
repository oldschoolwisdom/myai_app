import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ws_event.dart';
import '../models/permission_request.dart';
import '../models/role.dart';
import '../services/websocket_service.dart';
import 'env_provider.dart';
import 'roles_provider.dart';
import 'messages_provider.dart';
import 'permission_provider.dart';

part 'connection_provider.g.dart';

@Riverpod(keepAlive: true)
class Connection extends _$Connection {
  WebSocketService? _wsService;

  @override
  ConnectionStatus build() => ConnectionStatus.disconnected;

  Future<void> connect() async {
    final envService = ref.read(envProvider);
    final portStr = envService.get('AI_SERVER_PORT') ?? '7788';
    final port = int.tryParse(portStr) ?? 7788;

    _wsService?.dispose();
    _wsService = WebSocketService(port: port);
    _wsService!.status.addListener(() {
      state = _wsService!.status.value;
    });

    _wsService!.events.listen(_handleEvent);
    await _wsService!.connect();
  }

  void disconnect() {
    _wsService?.disconnect();
    state = ConnectionStatus.disconnected;
  }

  void _handleEvent(WsEvent event) {
    final roleId = event.roleId;

    switch (event.type) {
      case 'role.output':
        final chunk = event.payload['chunk'] as String? ?? '';
        ref.read(messagesProvider(roleId).notifier).appendChunk(chunk);

      case 'role.output_end':
        ref.read(messagesProvider(roleId).notifier).finalizeAssistant();

      case 'role.tool_call':
        final tool = event.payload['tool'] as String? ?? '';
        // arguments can be a Map (structured) or String; convert to readable string
        final rawArgs = event.payload['arguments'];
        final command = switch (rawArgs) {
          final String s => s,
          final Map<dynamic, dynamic> m => m.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', '),
          _ => '',
        };
        ref.read(messagesProvider(roleId).notifier).addToolCall(tool, command);

      case 'role.status':
        final statusStr = event.payload['status'] as String? ?? 'idle';
        final status = AgentStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => AgentStatus.idle,
        );
        ref.read(rolesProvider.notifier).updateRoleStatus(roleId, status);

      case 'role.error':
        ref.read(rolesProvider.notifier).updateRoleStatus(roleId, AgentStatus.error);

      case 'role.permission_request':
        final question = event.payload['question'] as String? ?? '';
        final choices = (event.payload['choices'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final requestId = event.payload['request_id'] as String? ?? '';
        ref.read(permissionsProvider.notifier).addRequest(
              PermissionRequest(
                requestId: requestId,
                roleId: roleId,
                question: question,
                choices: choices,
              ),
            );
    }
  }
}
