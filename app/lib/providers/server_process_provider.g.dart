// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_process_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServerProcess)
final serverProcessProvider = ServerProcessProvider._();

final class ServerProcessProvider
    extends $NotifierProvider<ServerProcess, ServerProcessState> {
  ServerProcessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverProcessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverProcessHash();

  @$internal
  @override
  ServerProcess create() => ServerProcess();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerProcessState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerProcessState>(value),
    );
  }
}

String _$serverProcessHash() => r'25e3992e7a576b2281737297e1f3e6907e7c9d8b';

abstract class _$ServerProcess extends $Notifier<ServerProcessState> {
  ServerProcessState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ServerProcessState, ServerProcessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServerProcessState, ServerProcessState>,
              ServerProcessState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
