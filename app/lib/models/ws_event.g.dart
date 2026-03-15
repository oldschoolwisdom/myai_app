// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WsEvent _$WsEventFromJson(Map<String, dynamic> json) => _WsEvent(
  type: json['type'] as String,
  roleId: json['role_id'] as String,
  payload: json['payload'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$WsEventToJson(_WsEvent instance) => <String, dynamic>{
  'type': instance.type,
  'role_id': instance.roleId,
  'payload': instance.payload,
};
