import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_config.dart';
import '../models/role_config.dart';
import '../services/role_config_service.dart';
import 'env_provider.dart';
import 'sdk_server_service_provider.dart';
import 'server_process_provider.dart';
import 'server_binary_path_provider.dart';
import 'connection_provider.dart';
import 'roles_provider.dart';
import 'startup_prefs_provider.dart';
import 'enabled_roles_provider.dart';
import 'scanned_roles_provider.dart';
import 'quick_phrases_provider.dart';

part 'app_startup_provider.g.dart';

enum StartupPhase {
  idle,
  loadingEnv,
  startingServer,
  configuring,
  connecting,
  ready,
  error,
}

enum LogLevel { info, ok, warn, fail }

class StartupLog {
  const StartupLog(this.level, this.message);
  final LogLevel level;
  final String message;
}

class StartupState {
  const StartupState({
    this.phase = StartupPhase.idle,
    this.error,
    this.logs = const [],
  });
  final StartupPhase phase;
  final String? error;
  final List<StartupLog> logs;

  StartupState copyWith({
    StartupPhase? phase,
    String? error,
    List<StartupLog>? logs,
  }) =>
      StartupState(
        phase: phase ?? this.phase,
        error: error ?? this.error,
        logs: logs ?? this.logs,
      );
}

@Riverpod(keepAlive: true)
class AppStartup extends _$AppStartup {
  @override
  StartupState build() => const StartupState();

  void _log(LogLevel level, String message) {
    state = state.copyWith(logs: [...state.logs, StartupLog(level, message)]);
  }

  /// [forceConnect] overrides AUTO_CONNECT=false so manual "連線" always establishes WS.
  Future<void> initialize({bool forceConnect = false}) async {
    // Reset logs on each attempt
    state = const StartupState(phase: StartupPhase.loadingEnv, logs: []);
    _log(LogLevel.info, '開始啟動序列…');

    try {
      // 1. Load .env
      final envService = ref.read(envProvider);
      await envService.load();
      _log(LogLevel.ok, '.env 載入完成');

      // 1b. Initialize startup prefs from .env flags
      final prefs = ref.read(startupPrefsProvider.notifier);
      prefs.initFromEnv(envService);
      final currentPrefs = ref.read(startupPrefsProvider);
      _log(LogLevel.info,
          'AUTO_START_SERVER=${currentPrefs.autoStartServer}  AUTO_CONNECT=${currentPrefs.autoConnect}');

      // 1c. Reload enabled roles now that env is loaded (build() ran before load()).
      ref.read(enabledRolesProvider.notifier).reloadFromEnv();

      // 1d. Load quick phrases from disk.
      await ref.read(quickPhrasesProvider.notifier).loadFromDisk();

      // 2. Resolve project root
      final projectRoot = _resolveProjectRoot();
      _log(LogLevel.info, '專案根目錄：$projectRoot');

      // 3. Start Go server binary (skipped if AUTO_START_SERVER=false)
      state = state.copyWith(phase: StartupPhase.startingServer);
      if (!currentPrefs.autoStartServer) {
        _log(LogLevel.info, 'AUTO_START_SERVER=false，跳過 SDK Server 啟動');
      } else {
        final binaryOverride = ref.read(serverBinaryPathProvider);
        final binaryPath = binaryOverride ??
            envService.get('AI_SERVER_BINARY') ??
            '$projectRoot/server/code/sdk-server';
        _log(LogLevel.info, 'Server binary：$binaryPath');

        final binFile = File(binaryPath);
        if (!await binFile.exists()) {
          _log(LogLevel.fail, 'Binary 不存在：$binaryPath');
        } else {
          try {
            await ref
                .read(serverProcessProvider.notifier)
                .startWithPath(binaryPath);
            _log(LogLevel.ok, 'Server 已啟動（或已在執行中）');
          } catch (e) {
            _log(LogLevel.warn, '啟動 binary 失敗：$e（嘗試連線現有 server）');
          }
        }
      }

      // 4. Scan roles from local prompts and pre-populate rolesProvider.
      state = state.copyWith(phase: StartupPhase.configuring);
      final roleConfigService = RoleConfigService(projectRoot: projectRoot);
      final localRoles = await roleConfigService.loadRoles();
      _log(LogLevel.info, '掃描到 ${localRoles.length} 個角色');
      ref.read(rolesProvider.notifier)
          .seedFromConfig(localRoles.map((r) => r.id).toList());
      ref.read(scannedRolesProvider.notifier).setRoles(localRoles);

      // 4b. Initialise enabled-roles from scan (new roles default to enabled).
      await ref.read(enabledRolesProvider.notifier)
          .initFromScanned(localRoles.map((r) => r.id).toList());

      // 5. Check reachability
      final sdkService = ref.read(sdkServerServiceProvider);
      final isReachable = await sdkService.isReachable();

      if (!isReachable) {
        _log(LogLevel.fail, 'localhost:7788 無回應，跳過設定與 WebSocket');
        state = state.copyWith(phase: StartupPhase.ready);
        return;
      }
      _log(LogLevel.ok, 'localhost:7788 可連線');

      // 6. Configure — only send enabled roles.
      try {
        final enabledIds = ref.read(enabledRolesProvider);
        final rolesToConfigure =
            localRoles.where((r) => enabledIds.contains(r.id)).toList();
        _log(LogLevel.info, '啟用角色：${rolesToConfigure.map((r) => r.id).join(', ')}');
        const auth = AuthConfig.copilot(githubToken: '');
        await sdkService.configure(auth, rolesToConfigure);
        _log(LogLevel.ok, 'POST /configure 成功');
      } catch (e) {
        _log(LogLevel.warn, '/configure 失敗：$e（繼續嘗試連線）');
      }

      // 7. Connect WebSocket (skipped if AUTO_CONNECT=false AND not forced)
      state = state.copyWith(phase: StartupPhase.connecting);
      if (!forceConnect && !ref.read(startupPrefsProvider).autoConnect) {
        _log(LogLevel.info, 'AUTO_CONNECT=false，跳過 WebSocket 連線');
      } else {
        try {
          await ref.read(connectionProvider.notifier).connect();
          _log(LogLevel.ok, 'WebSocket 已連線');
          await ref.read(rolesProvider.notifier).loadRoles();
          _log(LogLevel.ok, '角色列表載入完成');
        } catch (e) {
          _log(LogLevel.fail, 'WebSocket 連線失敗：$e');
        }
      }

      state = state.copyWith(phase: StartupPhase.ready);
    } catch (e) {
      _log(LogLevel.fail, '未預期錯誤：$e');
      state = state.copyWith(phase: StartupPhase.error, error: e.toString());
    }
  }

  /// Stop the running server process and restart the full startup sequence.
  Future<void> restart() async {
    _log(LogLevel.info, '正在停止 SDK Server…');
    try {
      await ref.read(serverProcessProvider.notifier).stop();
      _log(LogLevel.ok, 'SDK Server 已停止');
    } catch (e) {
      _log(LogLevel.warn, '停止 server 時發生錯誤：$e（繼續重啟）');
    }
    await initialize();
  }

  /// Configure the SDK server and connect WebSocket — for use when the server
  /// is already running but the app needs to (re)establish the session.
  /// Skips server start; always connects WS regardless of AUTO_CONNECT.
  Future<void> connectWs() async {
    state = state.copyWith(phase: StartupPhase.configuring, logs: [
      ...state.logs,
      const StartupLog(LogLevel.info, 'WebSocket 手動連線…'),
    ]);

    try {
      final projectRoot = _resolveProjectRoot();
      final roleConfigService = RoleConfigService(projectRoot: projectRoot);
      final localRoles = await roleConfigService.loadRoles();
      _log(LogLevel.info, '掃描到 ${localRoles.length} 個角色');
      ref.read(rolesProvider.notifier).seedFromConfig(localRoles.map((r) => r.id).toList());
      ref.read(scannedRolesProvider.notifier).setRoles(localRoles);

      await ref.read(enabledRolesProvider.notifier)
          .initFromScanned(localRoles.map((r) => r.id).toList());

      final sdkService = ref.read(sdkServerServiceProvider);
      final isReachable = await sdkService.isReachable();
      if (!isReachable) {
        _log(LogLevel.fail, 'localhost:7788 無回應');
        state = state.copyWith(phase: StartupPhase.ready);
        return;
      }

      final enabledIds = ref.read(enabledRolesProvider);
      final rolesToConfigure =
          localRoles.where((r) => enabledIds.contains(r.id)).toList();
      _log(LogLevel.info, '啟用角色：${rolesToConfigure.map((r) => r.id).join(', ')}');
      const auth = AuthConfig.copilot(githubToken: '');
      await sdkService.configure(auth, rolesToConfigure);
      _log(LogLevel.ok, 'POST /configure 成功');

      state = state.copyWith(phase: StartupPhase.connecting);
      await ref.read(connectionProvider.notifier).connect();
      _log(LogLevel.ok, 'WebSocket 已連線');
      await ref.read(rolesProvider.notifier).loadRoles();
      _log(LogLevel.ok, '角色列表載入完成');
    } catch (e) {
      _log(LogLevel.fail, '連線失敗：$e');
    }

    state = state.copyWith(phase: StartupPhase.ready);
  }

  /// Start only the SDK Server (without running the full startup sequence).
  Future<void> startServerOnly() async {
    state = state.copyWith(phase: StartupPhase.startingServer);
    _log(LogLevel.info, '手動啟動 SDK Server…');
    final envService = ref.read(envProvider);
    final projectRoot = _resolveProjectRoot();
    final binaryOverride = ref.read(serverBinaryPathProvider);
    final binaryPath = binaryOverride ??
        envService.get('AI_SERVER_BINARY') ??
        '$projectRoot/server/code/sdk-server';
    try {
      await ref.read(serverProcessProvider.notifier).startWithPath(binaryPath);
      _log(LogLevel.ok, 'SDK Server 已啟動');
    } catch (e) {
      _log(LogLevel.fail, '啟動失敗：$e');
    }
    state = state.copyWith(phase: StartupPhase.ready);
  }

  /// Enable a single role: configure it on the server and mark it enabled.
  Future<void> enableRole(RoleConfig role) async {
    try {
      const auth = AuthConfig.copilot(githubToken: '');
      await ref.read(sdkServerServiceProvider).configure(auth, [role]);
      await ref.read(enabledRolesProvider.notifier).enable(role.id);
    } catch (e) {
      _log(LogLevel.warn, '啟用角色 ${role.id} 失敗：$e');
    }
  }

  /// Disable a single role: delete it from the server and mark it disabled.
  Future<void> disableRole(String roleId) async {
    try {
      await ref.read(sdkServerServiceProvider).deleteRole(roleId);
    } catch (_) {}
    await ref.read(enabledRolesProvider.notifier).disable(roleId);
  }

  /// Remove a role entry entirely (for prompt-missing orphans).
  Future<void> removeRoleEntry(String roleId) async {
    try {
      await ref.read(sdkServerServiceProvider).deleteRole(roleId);
    } catch (_) {}
    await ref.read(enabledRolesProvider.notifier).remove(roleId);
    ref.read(rolesProvider.notifier).removeRole(roleId);
  }

  String _resolveProjectRoot() {
    // In development (flutter run), Platform.executable is something like
    // /Users/.../myai/app/code/build/macos/Build/Products/Debug/myai.app/...
    // We walk up from the executable to find the directory containing
    // both 'server/' and 'ai/' as a sanity check.
    //
    // Fallback chain:
    //  1. Walk up from Platform.executable looking for project root markers
    //  2. Walk up from Directory.current (works in flutter run dev mode)
    //  3. Return Directory.current as last resort

    // Try executable path first
    final execDir = File(Platform.executable).parent;
    final candidate = _findProjectRoot(execDir) ??
        _findProjectRoot(Directory(Directory.current.path)) ??
        Directory.current.path;
    return candidate;
  }

  /// Walk up from [dir] until we find a directory containing both
  /// 'server' and 'ai' subdirectories (project root markers).
  String? _findProjectRoot(Directory dir) {
    var current = dir;
    for (var i = 0; i < 12; i++) {
      final hasServer = Directory('${current.path}/server').existsSync();
      final hasAi = Directory('${current.path}/ai').existsSync();
      if (hasServer && hasAi) return current.path;
      final parent = current.parent;
      if (parent.path == current.path) break; // filesystem root
      current = parent;
    }
    return null;
  }
}
