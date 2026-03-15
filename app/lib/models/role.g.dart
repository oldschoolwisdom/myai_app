// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Role _$RoleFromJson(Map<String, dynamic> json) => _Role(
  id: json['id'] as String,
  status:
      $enumDecodeNullable(_$AgentStatusEnumMap, json['status']) ??
      AgentStatus.offline,
  currentTask: json['currentTask'] as String?,
);

Map<String, dynamic> _$RoleToJson(_Role instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$AgentStatusEnumMap[instance.status]!,
  'currentTask': instance.currentTask,
};

const _$AgentStatusEnumMap = {
  AgentStatus.offline: 'offline',
  AgentStatus.idle: 'idle',
  AgentStatus.running: 'running',
  AgentStatus.waiting: 'waiting',
  AgentStatus.done: 'done',
  AgentStatus.error: 'error',
};
