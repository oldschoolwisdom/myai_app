import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_event.freezed.dart';
part 'ws_event.g.dart';

@freezed
abstract class WsEvent with _$WsEvent {
  const factory WsEvent({
    required String type,
    @JsonKey(name: 'role_id') required String roleId,
    @Default({}) Map<String, dynamic> payload,
  }) = _WsEvent;

  factory WsEvent.fromJson(Map<String, dynamic> json) => _$WsEventFromJson(json);
}
