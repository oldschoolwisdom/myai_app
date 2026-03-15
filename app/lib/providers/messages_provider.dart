import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/message.dart';

part 'messages_provider.g.dart';

@Riverpod(keepAlive: true)
class Messages extends _$Messages {
  String? _pendingChunk;

  @override
  List<Message> build(String roleId) => [];

  void appendChunk(String chunk) {
    _pendingChunk = (_pendingChunk ?? '') + chunk;
    // Update last message if it's an ongoing assistant message
    if (state.isNotEmpty && state.last.role == MessageRole.assistant) {
      final updated = state.last.copyWith(content: state.last.content + chunk);
      state = [...state.sublist(0, state.length - 1), updated];
    } else {
      state = [
        ...state,
        Message(
          role: MessageRole.assistant,
          content: chunk,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  void finalizeAssistant() {
    _pendingChunk = null;
  }

  void addToolCall(String toolName, String command) {
    state = [
      ...state,
      Message(
        role: MessageRole.tool,
        content: command,
        timestamp: DateTime.now(),
        toolName: toolName,
      ),
    ];
  }

  void addUserMessage(String text) {
    state = [
      ...state,
      Message(
        role: MessageRole.user,
        content: text,
        timestamp: DateTime.now(),
      ),
    ];
  }
}
