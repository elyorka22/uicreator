import 'dart:io';

import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/data/repositories/provider_config_repository_impl.dart';
import 'package:ai_ui_studio/data/storage/provider_config_store.dart';
import 'package:ai_ui_studio/data/storage/secure_key_store.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryStorage extends FlutterSecureStorage {
  _MemoryStorage() : super();

  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
    MacOsOptions? mOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  late Directory tempDir;
  late ProviderConfigRepositoryImpl repo;
  late _MemoryStorage memory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('ai_ui_studio_test_');
    memory = _MemoryStorage();
    repo = ProviderConfigRepositoryImpl(
      secureKeyStore: SecureKeyStore(storage: memory),
      configStore: ProviderConfigStore(
        documentsDirectoryOverride: () => tempDir,
      ),
      prefs: await SharedPreferences.getInstance(),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves provider metadata without writing api key into json file', () async {
    final saved = await repo.saveProvider(
      config: const AiProviderConfig(
        id: 'p1',
        type: AiProviderType.openaiCompatible,
        displayName: 'OpenAI',
        baseUrl: 'https://api.openai.com/v1',
        modelId: 'gpt-4o-mini',
        credentialKeyId: '',
      ),
      apiKey: 'sk-secret-value-9999',
    );

    expect(saved.hasCredential, isTrue);
    expect(saved.lastFourOfKey, '9999');
    expect(await repo.readApiKey(saved.credentialKeyId), 'sk-secret-value-9999');

    final file = File('${tempDir.path}/provider_configs.json');
    final raw = await file.readAsString();
    expect(raw, isNot(contains('sk-secret-value-9999')));
    expect(raw, contains('p1'));
  });

  test('blocks http urls unless insecure opt-in is enabled', () async {
    expect(
      () => repo.saveProvider(
        config: const AiProviderConfig(
          id: 'local',
          type: AiProviderType.openaiCompatible,
          displayName: 'Local',
          baseUrl: 'http://localhost:8080/v1',
          modelId: 'local-model',
          credentialKeyId: '',
        ),
        apiKey: 'local-key',
      ),
      throwsA(isA<ValidationFailure>()),
    );

    await repo.setAllowInsecureHttp(true);
    final saved = await repo.saveProvider(
      config: const AiProviderConfig(
        id: 'local',
        type: AiProviderType.openaiCompatible,
        displayName: 'Local',
        baseUrl: 'http://localhost:8080/v1',
        modelId: 'local-model',
        credentialKeyId: '',
      ),
      apiKey: 'local-key',
    );
    expect(saved.baseUrl, 'http://localhost:8080/v1');
  });
}
