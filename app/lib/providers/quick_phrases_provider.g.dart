// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_phrases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuickPhrases)
final quickPhrasesProvider = QuickPhrasesProvider._();

final class QuickPhrasesProvider
    extends $NotifierProvider<QuickPhrases, List<QuickPhrase>> {
  QuickPhrasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickPhrasesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickPhrasesHash();

  @$internal
  @override
  QuickPhrases create() => QuickPhrases();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<QuickPhrase> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<QuickPhrase>>(value),
    );
  }
}

String _$quickPhrasesHash() => r'9debaa538d1e4527a593bb37a5b7b9c0f1f3ea21';

abstract class _$QuickPhrases extends $Notifier<List<QuickPhrase>> {
  List<QuickPhrase> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<QuickPhrase>, List<QuickPhrase>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<QuickPhrase>, List<QuickPhrase>>,
              List<QuickPhrase>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
