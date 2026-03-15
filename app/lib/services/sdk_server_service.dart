import 'package:dio/dio.dart';
import '../models/role.dart';
import '../models/auth_config.dart';
import '../models/role_config.dart';

class SdkServerService {
  SdkServerService({int port = 7788}) {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:$port',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  late final Dio _dio;

  Future<void> configure(AuthConfig auth, List<RoleConfig> roles) async {
    final authJson = switch (auth) {
      CopilotAuthConfig(:final githubToken) => {
          'mode': 'copilot',
          'github_token': githubToken,
        },
      ByokAuthConfig(:final apiKey, :final baseUrl, :final type, :final model) => {
          'mode': 'byok',
          'provider': {
            'type': type,
            'base_url': baseUrl,
            'api_key': apiKey,
          },
          'model': model,
        },
    };
    final rolesJson = roles
        .map((r) => {
              'id': r.id,
              'prompt_path': r.promptPath,
              'work_dir': r.workDir,
              'model': r.model,
            })
        .toList();
    await _dio.post('/configure', data: {'auth': authJson, 'roles': rolesJson});
  }

  Future<List<Role>> getRoles() async {
    final response = await _dio.get('/roles');
    final list = (response.data['roles'] as List?) ?? [];
    return list.map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage(String roleId, String text) async {
    await _dio.post('/roles/$roleId/message', data: {'text': text});
  }

  Future<void> interrupt(String roleId) async {
    await _dio.post('/roles/$roleId/interrupt');
  }

  Future<void> respondToPermission(
      String roleId, String requestId, bool allowed) async {
    await _dio.post(
      '/roles/$roleId/permission_response',
      data: {'request_id': requestId, 'allowed': allowed},
    );
  }

  /// Returns true if the server process is reachable (any 200 response).
  Future<void> deleteRole(String roleId) async {
    await _dio.delete('/roles/$roleId');
  }

  Future<bool> isReachable() async {
    try {
      await _dio.get('/auth/status');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkAuth() async {
    try {
      final response = await _dio.get('/auth/status');
      return response.data['authenticated'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns available model IDs from the Copilot SDK.
  Future<List<String>> fetchModels() async {
    final response = await _dio.get('/models');
    final list = response.data as List<dynamic>;
    return list
        .map((m) => (m as Map<String, dynamic>)['id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();
  }
}
