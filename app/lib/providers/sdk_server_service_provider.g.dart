// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_server_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sdkServerService)
final sdkServerServiceProvider = SdkServerServiceProvider._();

final class SdkServerServiceProvider
    extends
        $FunctionalProvider<
          SdkServerService,
          SdkServerService,
          SdkServerService
        >
    with $Provider<SdkServerService> {
  SdkServerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sdkServerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sdkServerServiceHash();

  @$internal
  @override
  $ProviderElement<SdkServerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SdkServerService create(Ref ref) {
    return sdkServerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SdkServerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SdkServerService>(value),
    );
  }
}

String _$sdkServerServiceHash() => r'96220c124ca8de3ab8eb072845d62071d06a4c29';
