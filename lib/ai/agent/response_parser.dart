import 'dart:convert';

import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';

class GenerationEnvelope {
  const GenerationEnvelope({
    required this.componentName,
    required this.description,
    required this.platform,
    required this.sourceFiles,
    required this.tags,
    required this.warnings,
    this.schemaJson,
    this.schemaValid = false,
    this.schemaErrors = const [],
    this.rawJson,
  });

  final String componentName;
  final String description;
  final TargetPlatformKind platform;
  final String? schemaJson;
  final bool schemaValid;
  final List<String> schemaErrors;
  final List<SourceFile> sourceFiles;
  final List<String> tags;
  final List<String> warnings;
  final Map<String, dynamic>? rawJson;

  bool get hasSchema => schemaJson != null && schemaJson!.isNotEmpty;

  bool get hasHtmlPreview =>
      ComponentPreviewAssets.fromFiles(sourceFiles) != null;
}

class ResponseParseException implements Exception {
  ResponseParseException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ResponseParser {
  /// Extract JSON object from model output that may include fences or prose.
  static Map<String, dynamic> extractJsonObject(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw ResponseParseException('Empty model response');
    }

    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final fenceMatch = fence.firstMatch(trimmed);
    final candidate = fenceMatch != null ? fenceMatch.group(1)!.trim() : trimmed;

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}

    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final slice = candidate.substring(start, end + 1);
      final decoded = jsonDecode(slice);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }

    throw ResponseParseException('Could not parse JSON object from model response');
  }

  static List<SourceFile> _filesFromBlock(dynamic block) {
    final out = <SourceFile>[];
    if (block is! Map) return out;
    final files = block['files'];
    if (files is List) {
      for (final file in files.whereType<Map>()) {
        out.add(SourceFile.fromJson(Map<String, dynamic>.from(file)));
      }
    } else if (block['content'] != null) {
      final language = block['language']?.toString() ?? 'txt';
      out.add(
        SourceFile(
          path: 'component.${_ext(language)}',
          content: block['content'].toString(),
        ),
      );
    }
    return out;
  }

  static List<SourceFile> _mergeFiles(List<SourceFile> primary, List<SourceFile> secondary) {
    final byPath = <String, SourceFile>{};
    for (final f in secondary) {
      byPath[f.path] = f;
    }
    for (final f in primary) {
      byPath[f.path] = f;
    }
    return byPath.values.toList();
  }

  static GenerationEnvelope parse(
    String raw, {
    TargetPlatformKind fallbackPlatform = TargetPlatformKind.visual,
  }) {
    final map = extractJsonObject(raw);
    final name = (map['componentName'] ?? map['name'] ?? 'GeneratedComponent')
        .toString();
    final description = (map['description'] ?? '').toString();
    final platform = TargetPlatformKindX.fromWire(
      map['platform']?.toString() ?? fallbackPlatform.wireName,
    );

    String? schemaJson;
    var schemaValid = false;
    var schemaErrors = <String>[];
    final schemaRaw = map['schema'];
    if (schemaRaw is Map) {
      final schemaMap = Map<String, dynamic>.from(schemaRaw);
      final validation = UiSchemaValidator.validate(schemaMap);
      schemaJson = jsonEncode(schemaMap);
      schemaValid = validation.isValid;
      schemaErrors = validation.errors;
    } else if (schemaRaw != null) {
      schemaErrors = ['schema must be an object or null'];
    }

    final previewFiles = _filesFromBlock(map['preview']);
    final sourceFiles = _mergeFiles(_filesFromBlock(map['source']), previewFiles);

    final tags = (map['tags'] is List)
        ? (map['tags'] as List).map((e) => e.toString()).toList()
        : <String>[];
    final warnings = (map['warnings'] is List)
        ? (map['warnings'] as List).map((e) => e.toString()).toList()
        : <String>[];

    if (!schemaValid && schemaJson != null) {
      warnings.add('Schema validation failed; HTML preview may still work.');
    }

    final hasPreview = ComponentPreviewAssets.fromFiles(sourceFiles) != null;
    if (sourceFiles.isEmpty && !schemaValid) {
      throw ResponseParseException(
        'Envelope has neither valid schema nor preview/source files',
      );
    }
    if (!hasPreview && platform == TargetPlatformKind.visual) {
      warnings.add('Missing HTML preview files; Studio will fall back to schema.');
    }

    return GenerationEnvelope(
      componentName: name,
      description: description,
      platform: platform,
      schemaJson: schemaValid || schemaJson != null ? schemaJson : null,
      schemaValid: schemaValid,
      schemaErrors: schemaErrors,
      sourceFiles: sourceFiles,
      tags: tags,
      warnings: warnings,
      rawJson: map,
    );
  }

  static String _ext(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return 'dart';
      case 'jsx':
      case 'react':
        return 'jsx';
      case 'tsx':
        return 'tsx';
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'js':
      case 'javascript':
        return 'js';
      default:
        return 'txt';
    }
  }
}
