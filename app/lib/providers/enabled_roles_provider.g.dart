// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enabled_roles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(EnabledRoles)
final enabledRolesProvider = EnabledRolesProvider._();

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
final class EnabledRolesProvider
    extends $NotifierProvider<EnabledRoles, Set<String>> {
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
  EnabledRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledRolesHash();

  @$internal
  @override
  EnabledRoles create() => EnabledRoles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$enabledRolesHash() => r'523160fe1c790dc3257844c6d5923d31da5421d7';

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

abstract class _$EnabledRoles extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
