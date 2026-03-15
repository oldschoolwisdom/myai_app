import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/role_config.dart';

part 'scanned_roles_provider.g.dart';

/// Holds the list of RoleConfig discovered during the last prompt scan.
/// Updated by AppStartup after scanning ai/prompts/.
@Riverpod(keepAlive: true)
class ScannedRoles extends _$ScannedRoles {
  @override
  List<RoleConfig> build() => [];

  void setRoles(List<RoleConfig> roles) {
    state = roles;
  }
}
