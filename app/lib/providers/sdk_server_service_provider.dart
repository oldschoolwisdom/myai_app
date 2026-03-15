import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/sdk_server_service.dart';
import 'env_provider.dart';

part 'sdk_server_service_provider.g.dart';

@Riverpod(keepAlive: true)
SdkServerService sdkServerService(Ref ref) {
  final envService = ref.read(envProvider);
  final portStr = envService.get('AI_SERVER_PORT') ?? '7788';
  final port = int.tryParse(portStr) ?? 7788;
  return SdkServerService(port: port);
}
