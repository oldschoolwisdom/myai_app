// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Roles)
final rolesProvider = RolesProvider._();

final class RolesProvider extends $NotifierProvider<Roles, Map<String, Role>> {
  RolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rolesHash();

  @$internal
  @override
  Roles create() => Roles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Role> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Role>>(value),
    );
  }
}

String _$rolesHash() => r'74bf545395e0aa7f084a1596669103d00865545f';

abstract class _$Roles extends $Notifier<Map<String, Role>> {
  Map<String, Role> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Role>, Map<String, Role>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Role>, Map<String, Role>>,
              Map<String, Role>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
