// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Permissions)
final permissionsProvider = PermissionsProvider._();

final class PermissionsProvider
    extends $NotifierProvider<Permissions, Map<String, PermissionRequest>> {
  PermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionsHash();

  @$internal
  @override
  Permissions create() => Permissions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, PermissionRequest> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, PermissionRequest>>(
        value,
      ),
    );
  }
}

String _$permissionsHash() => r'bf3d4e7db37b8456fbf45c586145cffa67ea794b';

abstract class _$Permissions extends $Notifier<Map<String, PermissionRequest>> {
  Map<String, PermissionRequest> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, PermissionRequest>,
              Map<String, PermissionRequest>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, PermissionRequest>,
                Map<String, PermissionRequest>
              >,
              Map<String, PermissionRequest>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
