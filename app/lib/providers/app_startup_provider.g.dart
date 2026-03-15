// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppStartup)
final appStartupProvider = AppStartupProvider._();

final class AppStartupProvider
    extends $NotifierProvider<AppStartup, StartupState> {
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  AppStartup create() => AppStartup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartupState>(value),
    );
  }
}

String _$appStartupHash() => r'60b32fa1df1a50016eefb4a6e04b02ff4cb8058c';

abstract class _$AppStartup extends $Notifier<StartupState> {
  StartupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StartupState, StartupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StartupState, StartupState>,
              StartupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
