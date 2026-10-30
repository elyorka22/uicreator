import 'dart:convert';
import 'dart:io';

import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local JSON persistence for provider metadata (never stores API keys).
class ProviderConfigStore {
  ProviderConfigStore({Directory? Function()? documentsDirectoryOverride})
      : _documentsDirectoryOverride = documentsDirectoryOverride;

  final Directory? Function()? _documentsDirectoryOverride;

  Future<File> _file() async {
    final dir = _documentsDirectoryOverride?.call() ??
        await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, AppConstants.providerConfigsFileName));
  }

  Future<List<AiProviderConfig>> readAll() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return [];
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw StorageFailure('Provider config file is corrupted.');
      }
      return decoded
          .whereType<Map>()
          .map((e) => AiProviderConfig.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (e is StorageFailure) rethrow;
      throw StorageFailure('Failed to read provider configs.', cause: e);
    }
  }

  Future<void> writeAll(List<AiProviderConfig> configs) async {
    try {
      final file = await _file();
      final payload = jsonEncode(configs.map((e) => e.toJson()).toList());
      await file.writeAsString(payload);
    } catch (e) {
      throw StorageFailure('Failed to write provider configs.', cause: e);
    }
  }
}
