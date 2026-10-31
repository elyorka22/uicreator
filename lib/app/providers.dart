import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/ai/providers/anthropic_adapter.dart';
import 'package:ai_ui_studio/ai/providers/gemini_adapter.dart';
import 'package:ai_ui_studio/ai/providers/openai_compatible_adapter.dart';
import 'package:ai_ui_studio/ai/registry/provider_registry.dart';
import 'package:ai_ui_studio/core/logging/redacting_logger.dart';
import 'package:ai_ui_studio/data/repositories/provider_config_repository_impl.dart';
import 'package:ai_ui_studio/data/storage/provider_config_store.dart';
import 'package:ai_ui_studio/data/storage/secure_key_store.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:ai_ui_studio/domain/repositories/provider_config_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final redactingLoggerProvider = Provider<RedactingLogger>((ref) {
  return RedactingLogger();
});

final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return SecureKeyStore();
});

final providerConfigStoreProvider = Provider<ProviderConfigStore>((ref) {
  return ProviderConfigStore();
});

final providerConfigRepositoryProvider =
    Provider<ProviderConfigRepository>((ref) {
  return ProviderConfigRepositoryImpl(
    secureKeyStore: ref.watch(secureKeyStoreProvider),
    configStore: ref.watch(providerConfigStoreProvider),
  );
});

final aiDioFactoryProvider = Provider<AiDioFactory>((ref) {
  return AiDioFactory(ref.watch(redactingLoggerProvider));
});

final providerRegistryProvider = Provider<ProviderRegistry>((ref) {
  final dioFactory = ref.watch(aiDioFactoryProvider);
  return ProviderRegistry(
    openAiCompatibleAdapter: OpenAiCompatibleAdapter(dioFactory),
    anthropicAdapter: AnthropicAdapter(dioFactory),
    geminiAdapter: GeminiAdapter(dioFactory),
  );
});

final providerConfigsProvider =
    AsyncNotifierProvider<ProviderConfigsNotifier, List<AiProviderConfig>>(
  ProviderConfigsNotifier.new,
);

class ProviderConfigsNotifier extends AsyncNotifier<List<AiProviderConfig>> {
  @override
  Future<List<AiProviderConfig>> build() {
    return ref.read(providerConfigRepositoryProvider).listProviders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(providerConfigRepositoryProvider).listProviders(),
    );
  }

  Future<AiProviderConfig> save({
    required AiProviderConfig config,
    String? apiKey,
  }) async {
    final repo = ref.read(providerConfigRepositoryProvider);
    final saved = await repo.saveProvider(config: config, apiKey: apiKey);
    await refresh();
    return saved;
  }

  Future<void> delete(String id) async {
    await ref.read(providerConfigRepositoryProvider).deleteProvider(id);
    await refresh();
  }
}

final selectedProviderIdProvider =
    AsyncNotifierProvider<SelectedProviderIdNotifier, String?>(
  SelectedProviderIdNotifier.new,
);

class SelectedProviderIdNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.read(providerConfigRepositoryProvider).getSelectedProviderId();
  }

  Future<void> select(String? id) async {
    await ref.read(providerConfigRepositoryProvider).setSelectedProviderId(id);
    state = AsyncData(id);
  }
}

final allowInsecureHttpProvider =
    AsyncNotifierProvider<AllowInsecureHttpNotifier, bool>(
  AllowInsecureHttpNotifier.new,
);

class AllowInsecureHttpNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.read(providerConfigRepositoryProvider).getAllowInsecureHttp();
  }

  Future<void> setValue(bool value) async {
    await ref.read(providerConfigRepositoryProvider).setAllowInsecureHttp(value);
    state = AsyncData(value);
  }
}
