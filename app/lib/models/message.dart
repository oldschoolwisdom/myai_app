import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageRole { user, assistant, tool }

@freezed
abstract class Message with _$Message {
  const factory Message({
    required MessageRole role,
    required String content,
    required DateTime timestamp,
    String? toolName,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
