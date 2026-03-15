import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_request.freezed.dart';

@freezed
abstract class PermissionRequest with _$PermissionRequest {
  const factory PermissionRequest({
    required String requestId,
    required String roleId,
    required String question,
    @Default([]) List<String> choices,
  }) = _PermissionRequest;
}
