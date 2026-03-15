// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(env)
final envProvider = EnvProvider._();

final class EnvProvider
    extends $FunctionalProvider<EnvService, EnvService, EnvService>
    with $Provider<EnvService> {
  EnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envHash();

  @$internal
  @override
  $ProviderElement<EnvService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EnvService create(Ref ref) {
    return env(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvService>(value),
    );
  }
}

String _$envHash() => r'b8a14e0f9cd3a036c613b0053405b887ebfba0b9';
