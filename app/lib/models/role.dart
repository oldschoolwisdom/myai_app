import 'package:freezed_annotation/freezed_annotation.dart';

part 'role.freezed.dart';
part 'role.g.dart';

enum AgentStatus { offline, idle, running, waiting, done, error }

@freezed
abstract class Role with _$Role {
  const factory Role({
    required String id,
    @Default(AgentStatus.offline) AgentStatus status,
    String? currentTask,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}
