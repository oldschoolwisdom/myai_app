// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_roles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the list of RoleConfig discovered during the last prompt scan.
/// Updated by AppStartup after scanning ai/prompts/.

@ProviderFor(ScannedRoles)
final scannedRolesProvider = ScannedRolesProvider._();

/// Holds the list of RoleConfig discovered during the last prompt scan.
/// Updated by AppStartup after scanning ai/prompts/.
final class ScannedRolesProvider
    extends $NotifierProvider<ScannedRoles, List<RoleConfig>> {
  /// Holds the list of RoleConfig discovered during the last prompt scan.
  /// Updated by AppStartup after scanning ai/prompts/.
  ScannedRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scannedRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scannedRolesHash();

  @$internal
  @override
  ScannedRoles create() => ScannedRoles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RoleConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RoleConfig>>(value),
    );
  }
}

String _$scannedRolesHash() => r'7f43afaf9ef323e9f49603913ecc52eced1abdd1';

/// Holds the list of RoleConfig discovered during the last prompt scan.
/// Updated by AppStartup after scanning ai/prompts/.

abstract class _$ScannedRoles extends $Notifier<List<RoleConfig>> {
  List<RoleConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<RoleConfig>, List<RoleConfig>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RoleConfig>, List<RoleConfig>>,
              List<RoleConfig>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
