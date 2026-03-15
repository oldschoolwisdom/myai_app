import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/env_service.dart';
import 'env_provider.dart';

part 'startup_prefs_provider.g.dart';

class StartupPrefsState {
  const StartupPrefsState({
    this.autoStartServer = true,
    this.autoConnect = true,
  });

  final bool autoStartServer;
  final bool autoConnect;

  StartupPrefsState copyWith({bool? autoStartServer, bool? autoConnect}) =>
      StartupPrefsState(
        autoStartServer: autoStartServer ?? this.autoStartServer,
        autoConnect: autoConnect ?? this.autoConnect,
      );
}

@Riverpod(keepAlive: true)
class StartupPrefs extends _$StartupPrefs {
  @override
  StartupPrefsState build() => const StartupPrefsState();

  /// Called once after `.env` is loaded.
  /// `AUTO_START_SERVER=false` disables server auto-start.
  /// `AUTO_CONNECT=false`      disables WebSocket auto-connect.
  void initFromEnv(EnvService env) {
    state = StartupPrefsState(
      autoStartServer:
          env.get('AUTO_START_SERVER')?.toLowerCase() != 'false',
      autoConnect:
          env.get('AUTO_CONNECT')?.toLowerCase() != 'false',
    );
  }

  Future<void> setAutoStartServer(bool value) async {
    state = state.copyWith(autoStartServer: value);
    await ref.read(envProvider).set('AUTO_START_SERVER', value.toString());
  }

  Future<void> setAutoConnect(bool value) async {
    state = state.copyWith(autoConnect: value);
    await ref.read(envProvider).set('AUTO_CONNECT', value.toString());
  }
}
