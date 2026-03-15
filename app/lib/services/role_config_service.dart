import 'dart:io';
import '../models/role_config.dart';

class RoleConfigService {
  RoleConfigService({required this.projectRoot});

  final String projectRoot;

  Future<List<RoleConfig>> loadRoles() async {
    try {
      return await _scanFromPrompts();
    } catch (_) {
      return _hardcodedRoles();
    }
  }

  Future<List<RoleConfig>> _scanFromPrompts() async {
    final promptsDir = Directory('$projectRoot/ai/prompts');
    if (!await promptsDir.exists()) {
      throw Exception('No prompts directory');
    }
    final configs = <RoleConfig>[];
    await for (final entity in promptsDir.list()) {
      if (entity is File) {
        final name = entity.path.split('/').last;
        if (name.startsWith('ltc-') && name.endsWith('.md')) {
          final roleId = name.substring(4, name.length - 3);
          configs.add(RoleConfig(
            id: roleId,
            promptPath: entity.path,
            workDir: _workDirForRole(roleId, projectRoot),
          ));
        }
      }
    }
    return configs;
  }

  List<RoleConfig> _hardcodedRoles() {
    return [
      RoleConfig(
        id: 'app',
        promptPath: '$projectRoot/ai/ltc-app.md',
        workDir: '$projectRoot/app/code',
      ),
      RoleConfig(
        id: 'spec',
        promptPath: '$projectRoot/ai/prompts/ltc-spec.md',
        workDir: '$projectRoot/spec',
      ),
      RoleConfig(
        id: 'ux',
        promptPath: '$projectRoot/ai/prompts/ltc-ux.md',
        workDir: '$projectRoot/ux',
      ),
      RoleConfig(
        id: 'server',
        promptPath: '$projectRoot/ai/prompts/ltc-server.md',
        workDir: '$projectRoot/server/code',
      ),
    ];
  }

  static String _workDirForRole(String roleId, String projectRoot) {
    return switch (roleId) {
      'app' => '$projectRoot/app/code',
      'spec' => '$projectRoot/spec',
      'ux' => '$projectRoot/ux',
      'server' => '$projectRoot/server/code',
      'qa' => '$projectRoot/qa',
      'data' => '$projectRoot/data',
      _ => '$projectRoot/$roleId',
    };
  }
}
