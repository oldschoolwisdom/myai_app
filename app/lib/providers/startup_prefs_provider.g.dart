// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_prefs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StartupPrefs)
final startupPrefsProvider = StartupPrefsProvider._();

final class StartupPrefsProvider
    extends $NotifierProvider<StartupPrefs, StartupPrefsState> {
  StartupPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupPrefsHash();

  @$internal
  @override
  StartupPrefs create() => StartupPrefs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartupPrefsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartupPrefsState>(value),
    );
  }
}

String _$startupPrefsHash() => r'ebc2fbc443b90fb1d78008489110d1af040729c5';

abstract class _$StartupPrefs extends $Notifier<StartupPrefsState> {
  StartupPrefsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StartupPrefsState, StartupPrefsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StartupPrefsState, StartupPrefsState>,
              StartupPrefsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
