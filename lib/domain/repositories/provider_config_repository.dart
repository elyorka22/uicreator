import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';

abstract class ProviderConfigRepository {
  Future<List<AiProviderConfig>> listProviders();

  Future<AiProviderConfig?> getById(String id);

  Future<AiProviderConfig> saveProvider({
    required AiProviderConfig config,
    String? apiKey,
  });

  Future<void> deleteProvider(String id);

  Future<String?> readApiKey(String credentialKeyId);

  Future<String?> getSelectedProviderId();

  Future<void> setSelectedProviderId(String? id);

  Future<bool> getAllowInsecureHttp();

  Future<void> setAllowInsecureHttp(bool value);
}
