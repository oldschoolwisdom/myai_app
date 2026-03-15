// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleConfig _$RoleConfigFromJson(Map<String, dynamic> json) => _RoleConfig(
  id: json['id'] as String,
  promptPath: json['prompt_path'] as String,
  workDir: json['work_dir'] as String,
  model: json['model'] as String? ?? 'claude-sonnet-4.6',
);

Map<String, dynamic> _$RoleConfigToJson(_RoleConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prompt_path': instance.promptPath,
      'work_dir': instance.workDir,
      'model': instance.model,
    };
