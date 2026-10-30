import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/core/utils/url_validator.dart';
import 'package:ai_ui_studio/data/storage/provider_config_store.dart';
import 'package:ai_ui_studio/data/storage/secure_key_store.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:ai_ui_studio/domain/repositories/provider_config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProviderConfigRepositoryImpl implements ProviderConfigRepository {
  ProviderConfigRepositoryImpl({
    required SecureKeyStore secureKeyStore,
    required ProviderConfigStore configStore,
    SharedPreferences? prefs,
    Uuid? uuid,
  })  : _secureKeyStore = secureKeyStore,
        _configStore = configStore,
        _prefsOverride = prefs,
        _uuid = uuid ?? const Uuid();

  final SecureKeyStore _secureKeyStore;
  final ProviderConfigStore _configStore;
  final SharedPreferences? _prefsOverride;
  final Uuid _uuid;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  @override
  Future<List<AiProviderConfig>> listProviders() => _configStore.readAll();

  @override
  Future<AiProviderConfig?> getById(String id) async {
    final all = await listProviders();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<AiProviderConfig> saveProvider({
    required AiProviderConfig config,
    String? apiKey,
  }) async {
    final allowInsecure = await getAllowInsecureHttp();
    final urlResult = UrlValidator.validate(
      config.baseUrl,
      allowInsecureHttp: allowInsecure,
    );
    if (!urlResult.isValid) {
      throw ValidationFailure(urlResult.message ?? 'Invalid base URL');
    }

    final now = DateTime.now().toUtc();
    var credentialKeyId = config.credentialKeyId;
    if (credentialKeyId.isEmpty) {
      credentialKeyId = _uuid.v4();
    }

    String? lastFour = config.lastFourOfKey;
    var hasCredential = config.hasCredential;

    if (apiKey != null) {
      final trimmed = apiKey.trim();
      if (trimmed.isEmpty) {
        throw ValidationFailure('API key cannot be empty.');
      }
      await _secureKeyStore.write(credentialKeyId, trimmed);
      hasCredential = true;
      lastFour = trimmed.length <= 4
          ? trimmed
          : trimmed.substring(trimmed.length - 4);
    } else if (!hasCredential) {
      final existing = await _secureKeyStore.read(credentialKeyId);
      hasCredential = existing != null && existing.isNotEmpty;
    }

    final saved = config.copyWith(
      baseUrl: urlResult.normalizedUrl ?? config.baseUrl,
      credentialKeyId: credentialKeyId,
      hasCredential: hasCredential,
      lastFourOfKey: lastFour,
      createdAt: config.createdAt ?? now,
      updatedAt: now,
    );

    final all = await listProviders();
    final index = all.indexWhere((e) => e.id == saved.id);
    if (index >= 0) {
      all[index] = saved;
    } else {
      all.add(saved);
    }
    await _configStore.writeAll(all);

    final selected = await getSelectedProviderId();
    if (selected == null) {
      await setSelectedProviderId(saved.id);
    }

    return saved;
  }

  @override
  Future<void> deleteProvider(String id) async {
    final all = await listProviders();
    final target = all.where((e) => e.id == id).toList();
    if (target.isEmpty) return;

    await _secureKeyStore.delete(target.first.credentialKeyId);
    final remaining = all.where((e) => e.id != id).toList();
    await _configStore.writeAll(remaining);

    final selected = await getSelectedProviderId();
    if (selected == id) {
      await setSelectedProviderId(
        remaining.isEmpty ? null : remaining.first.id,
      );
    }
  }

  @override
  Future<String?> readApiKey(String credentialKeyId) =>
      _secureKeyStore.read(credentialKeyId);

  @override
  Future<String?> getSelectedProviderId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefsSelectedProviderId);
  }

  @override
  Future<void> setSelectedProviderId(String? id) async {
    final prefs = await _prefs;
    if (id == null) {
      await prefs.remove(AppConstants.prefsSelectedProviderId);
    } else {
      await prefs.setString(AppConstants.prefsSelectedProviderId, id);
    }
  }

  @override
  Future<bool> getAllowInsecureHttp() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.prefsAllowInsecureHttp) ?? false;
  }

  @override
  Future<void> setAllowInsecureHttp(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(AppConstants.prefsAllowInsecureHttp, value);
  }
}
