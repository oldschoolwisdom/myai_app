// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches available model IDs from the Copilot SDK via the server.
/// Re-fetches automatically whenever the WS connection state changes.
/// Falls back to a static list when the server is unreachable.

@ProviderFor(availableModels)
final availableModelsProvider = AvailableModelsProvider._();

/// Fetches available model IDs from the Copilot SDK via the server.
/// Re-fetches automatically whenever the WS connection state changes.
/// Falls back to a static list when the server is unreachable.

final class AvailableModelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Fetches available model IDs from the Copilot SDK via the server.
  /// Re-fetches automatically whenever the WS connection state changes.
  /// Falls back to a static list when the server is unreachable.
  AvailableModelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableModelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableModelsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return availableModels(ref);
  }
}

String _$availableModelsHash() => r'0f1307e72f2e14ebde55fe5a3ec0f113116d0880';
