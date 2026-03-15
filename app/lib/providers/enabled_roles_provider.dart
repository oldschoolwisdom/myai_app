import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'env_provider.dart';

part 'enabled_roles_provider.g.dart';

/// Tracks which roles are enabled (should be configured on the SDK server).
///
/// myai.env keys:
///   ENABLED_ROLES=app,server    — whitelist of currently-enabled role IDs
///   KNOWN_ROLES=app,spec,server — every role ID ever seen during a scan
///
/// Logic:
///   - New role (not in KNOWN_ROLES) → auto-enabled on first scan
///   - Role in KNOWN_ROLES but not ENABLED_ROLES → was explicitly disabled, keep off
///   - Toggle on/off → updates ENABLED_ROLES only; KNOWN_ROLES only grows
@Riverpod(keepAlive: true)
class EnabledRoles extends _$EnabledRoles {
  static const _enabledKey = 'ENABLED_ROLES';
  static const _knownKey   = 'KNOWN_ROLES';

  @override
  Set<String> build() {
    final env = ref.watch(envProvider);
    final raw = env.get(_enabledKey);
    if (raw == null || raw.trim().isEmpty) return {};
    return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
  }

  Set<String> _knownRoles() {
    final raw = ref.read(envProvider).get(_knownKey) ?? '';
    return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
  }

  /// Called after each prompt scan.
  /// Only auto-enables roles that have NEVER been seen before.
  /// Roles the user already disabled are left off.
  Future<void> initFromScanned(List<String> scannedIds) async {
    final known = _knownRoles();
    final brandNew = scannedIds.where((id) => !known.contains(id)).toList();

    if (brandNew.isEmpty) return;

    // Add brand-new roles to both enabled list and known list.
    state = {...state, ...brandNew};
    final newKnown = {...known, ...scannedIds};
    await _persistBoth(newKnown);
  }

  Future<void> enable(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    final known = {..._knownRoles(), id};
    await _persistBoth(known);
  }

  Future<void> disable(String id) async {
    if (!state.contains(id)) return;
    state = state.difference({id});
    final known = {..._knownRoles(), id};
    await _persistBoth(known);
  }

  /// Permanently remove a role entry (for prompt-missing orphans).
  Future<void> remove(String id) async {
    state = state.difference({id});
    final known = _knownRoles()..remove(id);
    await _persistBoth(known);
  }

  bool isEnabled(String id) => state.contains(id);

  /// Called by AppStartup after envService.load() completes.
  /// Re-reads ENABLED_ROLES from the now-loaded env file.
  void reloadFromEnv() {
    final env = ref.read(envProvider);
    final raw = env.get(_enabledKey);
    if (raw == null || raw.trim().isEmpty) {
      state = {};
    } else {
      state = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
    }
  }

  Future<void> _persistBoth(Set<String> known) async {
    final env = ref.read(envProvider);
    await env.set(_enabledKey, state.join(','));
    await env.set(_knownKey, known.join(','));
  }
}
