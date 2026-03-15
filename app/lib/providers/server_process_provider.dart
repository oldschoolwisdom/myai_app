import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/server_process_service.dart';
import 'env_provider.dart';

part 'server_process_provider.g.dart';

enum ServerStatus { stopped, starting, running, error }

class ServerProcessState {
  const ServerProcessState({
    this.status = ServerStatus.stopped,
    this.pid,
    this.error,
  });
  final ServerStatus status;
  final int? pid;
  final String? error;

  ServerProcessState copyWith({
    ServerStatus? status,
    int? pid,
    String? error,
  }) =>
      ServerProcessState(
        status: status ?? this.status,
        pid: pid ?? this.pid,
        error: error ?? this.error,
      );
}

@Riverpod(keepAlive: true)
class ServerProcess extends _$ServerProcess {
  final _service = ServerProcessService();

  @override
  ServerProcessState build() => const ServerProcessState();

  Future<void> start() async {
    final envService = ref.read(envProvider);
    final binaryPath = envService.get('AI_SERVER_BINARY') ?? '../server/code/sdk-server';
    await startWithPath(binaryPath);
  }

  Future<void> startWithPath(String binaryPath) async {
    state = state.copyWith(status: ServerStatus.starting);
    try {
      await _service.start(binaryPath: binaryPath);
      state = state.copyWith(status: ServerStatus.running);
    } on ServerBinaryNotFoundException catch (e) {
      state = state.copyWith(status: ServerStatus.error, error: e.toString());
      rethrow;
    } catch (e) {
      state = state.copyWith(status: ServerStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<void> stop() async {
    await _service.stop();
    state = state.copyWith(status: ServerStatus.stopped);
  }
}
