import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_provider_config.freezed.dart';
part 'ai_provider_config.g.dart';

enum AiProviderType {
  openaiCompatible,
  anthropic,
}

@freezed
class AiProviderConfig with _$AiProviderConfig {
  const factory AiProviderConfig({
    required String id,
    required AiProviderType type,
    required String displayName,
    required String baseUrl,
    required String modelId,
    /// Reference id used to look up the secret in secure storage. Never the key itself.
    required String credentialKeyId,
    @Default(false) bool hasCredential,
    String? lastFourOfKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AiProviderConfig;

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$AiProviderConfigFromJson(json);
}
