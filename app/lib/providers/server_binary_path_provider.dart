import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_binary_path_provider.g.dart';

/// User-configured override for the SDK server binary path.
/// keepAlive = true so the value persists even when no widget is watching.
/// null = use the default resolved from the executable location.
@Riverpod(keepAlive: true)
class ServerBinaryPath extends _$ServerBinaryPath {
  @override
  String? build() => null;

  void set(String? path) {
    state = (path == null || path.trim().isEmpty) ? null : path.trim();
  }
}
