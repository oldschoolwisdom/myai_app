import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/permission_request.dart';

part 'permission_provider.g.dart';

@Riverpod(keepAlive: true)
class Permissions extends _$Permissions {
  @override
  Map<String, PermissionRequest> build() => {};

  void addRequest(PermissionRequest request) {
    state = {...state, request.roleId: request};
  }

  void removeRequest(String roleId) {
    final newState = Map<String, PermissionRequest>.from(state);
    newState.remove(roleId);
    state = newState;
  }
}
