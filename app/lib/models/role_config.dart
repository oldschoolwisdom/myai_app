import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_config.freezed.dart';
part 'role_config.g.dart';

@freezed
abstract class RoleConfig with _$RoleConfig {
  const factory RoleConfig({
    required String id,
    @JsonKey(name: 'prompt_path') required String promptPath,
    @JsonKey(name: 'work_dir') required String workDir,
    @Default('claude-sonnet-4.6') String model,
  }) = _RoleConfig;

  factory RoleConfig.fromJson(Map<String, dynamic> json) => _$RoleConfigFromJson(json);
}
