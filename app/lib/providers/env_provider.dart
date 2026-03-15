import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/env_service.dart';

part 'env_provider.g.dart';

@Riverpod(keepAlive: true)
EnvService env(Ref ref) => EnvService();
