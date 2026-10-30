import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Android Keystore-backed storage for API credentials.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  final FlutterSecureStorage _storage;

  String storageKeyFor(String credentialKeyId) =>
      '${AppConstants.secureKeyPrefix}$credentialKeyId';

  Future<void> write(String credentialKeyId, String apiKey) async {
    try {
      await _storage.write(
        key: storageKeyFor(credentialKeyId),
        value: apiKey,
      );
    } catch (e) {
      throw StorageFailure('Failed to store API key securely.', cause: e);
    }
  }

  Future<String?> read(String credentialKeyId) async {
    try {
      return await _storage.read(key: storageKeyFor(credentialKeyId));
    } catch (e) {
      throw StorageFailure('Failed to read API key.', cause: e);
    }
  }

  Future<void> delete(String credentialKeyId) async {
    try {
      await _storage.delete(key: storageKeyFor(credentialKeyId));
    } catch (e) {
      throw StorageFailure('Failed to delete API key.', cause: e);
    }
  }
}
