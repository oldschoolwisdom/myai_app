// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Connection)
final connectionProvider = ConnectionProvider._();

final class ConnectionProvider
    extends $NotifierProvider<Connection, ConnectionStatus> {
  ConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionHash();

  @$internal
  @override
  Connection create() => Connection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionStatus>(value),
    );
  }
}

String _$connectionHash() => r'3a7e4861ccb5cc1b46c7487d7c66d3cc10e7dd74';

abstract class _$Connection extends $Notifier<ConnectionStatus> {
  ConnectionStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectionStatus, ConnectionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionStatus, ConnectionStatus>,
              ConnectionStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
