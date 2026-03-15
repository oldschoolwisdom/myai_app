import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_config.freezed.dart';

@freezed
sealed class AuthConfig with _$AuthConfig {
  const factory AuthConfig.copilot({required String githubToken}) = CopilotAuthConfig;
  const factory AuthConfig.byok({
    required String apiKey,
    required String baseUrl,
    @Default('openai') String type,
    @Default('gpt-4o') String model,
  }) = ByokAuthConfig;
}
