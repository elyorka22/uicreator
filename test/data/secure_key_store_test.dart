import 'package:ai_ui_studio/data/storage/secure_key_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

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
  test('stores and reads credentials under prefixed keys', () async {
    final memory = _MemoryStorage();
    final store = SecureKeyStore(storage: memory);

    await store.write('cred-1', 'sk-test-secret');
    expect(await store.read('cred-1'), 'sk-test-secret');
    expect(store.storageKeyFor('cred-1'), 'ai_cred_cred-1');

    await store.delete('cred-1');
    expect(await store.read('cred-1'), isNull);
  });
}
