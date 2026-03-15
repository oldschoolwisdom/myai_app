import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/role.dart';
import 'sdk_server_service_provider.dart';

part 'roles_provider.g.dart';

@Riverpod(keepAlive: true)
class Roles extends _$Roles {
  @override
  Map<String, Role> build() => {};

  Future<void> loadRoles() async {
    try {
      final service = ref.read(sdkServerServiceProvider);
      final roles = await service.getRoles();
      state = {for (final r in roles) r.id: r};
    } catch (_) {
      // Keep existing state on error
    }
  }

  /// Pre-populate roles from local config scan (before server responds).
  /// Only adds roles not already in state; preserves existing status.
  void seedFromConfig(List<String> roleIds) {
    final merged = Map<String, Role>.from(state);
    for (final id in roleIds) {
      merged.putIfAbsent(id, () => Role(id: id));
    }
    state = merged;
  }

  void updateRoleStatus(String roleId, AgentStatus status) {
    final existing = state[roleId];
    if (existing != null) {
      state = {...state, roleId: existing.copyWith(status: status)};
    } else {
      state = {...state, roleId: Role(id: roleId, status: status)};
    }
  }

  void removeRole(String roleId) {
    if (!state.containsKey(roleId)) return;
    state = Map.from(state)..remove(roleId);
  }
}
