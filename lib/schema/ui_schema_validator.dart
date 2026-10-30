import 'package:ai_ui_studio/schema/ui_node.dart';

class UiSchemaValidationException implements Exception {
  UiSchemaValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join('\n');
}

class UiSchemaValidationResult {
  const UiSchemaValidationResult({
    required this.isValid,
    required this.errors,
    this.document,
  });

  final bool isValid;
  final List<String> errors;
  final UiDocument? document;
}

class UiSchemaValidator {
  static const int maxNodes = 200;
  static const int maxDepth = 30;

  /// Validate raw JSON (already decoded Map) into a [UiDocument].
  static UiSchemaValidationResult validate(dynamic raw) {
    final errors = <String>[];
    if (raw is! Map) {
      return const UiSchemaValidationResult(
        isValid: false,
        errors: ['Root value must be a JSON object'],
      );
    }

    final map = Map<String, dynamic>.from(raw);
    final version = (map['\$schemaVersion'] ?? map['schemaVersion'] ?? '')
        .toString();
    if (version.isEmpty) {
      errors.add('Missing \$schemaVersion');
    } else if (version != '1.0') {
      errors.add('Unsupported \$schemaVersion "$version" (expected "1.0")');
    }

    if (map['root'] is! Map) {
      errors.add('Missing or invalid "root" object');
      return UiSchemaValidationResult(isValid: false, errors: errors);
    }

    try {
      final document = UiDocument.fromJson(map);
      _validateNode(document.root, path: 'root', depth: 1, errors: errors);

      if (document.nodeCount > maxNodes) {
        errors.add(
          'Document has ${document.nodeCount} nodes; max allowed is $maxNodes',
        );
      }

      if (errors.isNotEmpty) {
        return UiSchemaValidationResult(isValid: false, errors: errors);
      }
      return UiSchemaValidationResult(
        isValid: true,
        errors: const [],
        document: document,
      );
    } on FormatException catch (e) {
      errors.add(e.message);
      return UiSchemaValidationResult(isValid: false, errors: errors);
    } catch (e) {
      errors.add('Failed to parse schema: $e');
      return UiSchemaValidationResult(isValid: false, errors: errors);
    }
  }

  static UiDocument parseOrThrow(dynamic raw) {
    final result = validate(raw);
    if (!result.isValid || result.document == null) {
      throw UiSchemaValidationException(result.errors);
    }
    return result.document!;
  }

  static void _validateNode(
    UiNode node, {
    required String path,
    required int depth,
    required List<String> errors,
  }) {
    if (depth > maxDepth) {
      errors.add('$path exceeds max depth of $maxDepth');
      return;
    }

    if (!kSupportedUiNodeTypes.contains(node.type)) {
      // Unknown types are allowed as placeholders, but warn.
      errors.add('$path: unsupported type "${node.type}"');
    }

    if (node.type == 'text' &&
        node.propString('data') == null &&
        node.propString('text') == null) {
      errors.add('$path (text): missing props.data');
    }
    if (node.type == 'button' &&
        node.propString('label') == null &&
        node.propString('text') == null) {
      errors.add('$path (button): missing props.label');
    }
    if (node.type == 'image' &&
        node.propString('url') == null &&
        node.propString('src') == null) {
      errors.add('$path (image): missing props.url');
    }

    for (var i = 0; i < node.children.length; i++) {
      _validateNode(
        node.children[i],
        path: '$path/children[$i]',
        depth: depth + 1,
        errors: errors,
      );
    }
  }
}
