class AppConstants {
  static const String appName = 'AI UI Studio';
  static const String applicationId = 'com.aiuistudio.app';

  static const String openAiDefaultBaseUrl = 'https://api.openai.com/v1';
  static const String deepSeekDefaultBaseUrl = 'https://api.deepseek.com/v1';
  static const String anthropicDefaultBaseUrl = 'https://api.anthropic.com';
  static const String geminiDefaultBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String anthropicApiVersion = '2023-06-01';

  static const Duration httpConnectTimeout = Duration(seconds: 20);
  static const Duration httpReceiveTimeout = Duration(seconds: 120);

  static const String providerConfigsFileName = 'provider_configs.json';
  static const String prefsAllowInsecureHttp = 'allow_insecure_http';
  static const String prefsSelectedProviderId = 'selected_provider_id';

  static const String secureKeyPrefix = 'ai_cred_';
}
