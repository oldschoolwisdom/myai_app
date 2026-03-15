// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_binary_path_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User-configured override for the SDK server binary path.
/// keepAlive = true so the value persists even when no widget is watching.
/// null = use the default resolved from the executable location.

@ProviderFor(ServerBinaryPath)
final serverBinaryPathProvider = ServerBinaryPathProvider._();

/// User-configured override for the SDK server binary path.
/// keepAlive = true so the value persists even when no widget is watching.
/// null = use the default resolved from the executable location.
final class ServerBinaryPathProvider
    extends $NotifierProvider<ServerBinaryPath, String?> {
  /// User-configured override for the SDK server binary path.
  /// keepAlive = true so the value persists even when no widget is watching.
  /// null = use the default resolved from the executable location.
  ServerBinaryPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverBinaryPathProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverBinaryPathHash();

  @$internal
  @override
  ServerBinaryPath create() => ServerBinaryPath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$serverBinaryPathHash() => r'ad35fc65ea3ab1bfd37a445910cfe0c144293747';

/// User-configured override for the SDK server binary path.
/// keepAlive = true so the value persists even when no widget is watching.
/// null = use the default resolved from the executable location.

abstract class _$ServerBinaryPath extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
