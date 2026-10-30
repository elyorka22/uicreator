import 'package:ai_ui_studio/domain/entities/ui_component.dart';

class PromptBuilder {
  static String systemPrompt(TargetPlatformKind platform) {
    final platformLabel = platform.wireName;
    return '''
You are AI UI Studio's UI generation engine.
Return ONLY a single JSON object (no markdown fences, no commentary) with this shape:
{
  "componentName": "PascalOrReadableName",
  "description": "short description",
  "platform": "$platformLabel",
  "schema": {
    "\$schemaVersion": "1.0",
    "root": { "type": "...", "props": {}, "style": {}, "actions": {}, "children": [] }
  },
  "source": {
    "language": "${_language(platform)}",
    "files": [{ "path": "filename.ext", "content": "..." }]
  },
  "tags": ["tag"],
  "warnings": []
}

Universal UI Schema rules:
- \$schemaVersion must be "1.0".
- Supported node types: container, text, button, image, icon, row, column, stack, card, textField, checkbox, switch, divider, padding, scrollView, sizedBox, spacer, center, expanded, flexible.
- Colors use #RRGGBB or #AARRGGBB.
- Prefer nested layouts with row/column/card.
- text nodes need props.data; button nodes need props.label; image nodes need props.url.
- actions.onPressed may use {"type":"previewToast","message":"..."}.

Platform source rules:
- flutter: emit a reusable StatelessWidget Dart file.
- html: emit index.html (and optional styles.css / script.js files).
- react: emit a functional JSX component file.

If the UI is too complex for the schema, set "schema" to null, set generationMode conceptually as source-only by adding warning "source_only", and still provide source files.
Never include API keys or secrets.
''';
  }

  static String userPrompt({
    required String description,
    required TargetPlatformKind platform,
    String? regenerateHint,
  }) {
    final buffer = StringBuffer()
      ..writeln('Target platform: ${platform.wireName}')
      ..writeln('User request:')
      ..writeln(description.trim());
    if (regenerateHint != null && regenerateHint.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Regeneration notes:')
        ..writeln(regenerateHint.trim());
    }
    buffer.writeln(
      '\nRespond with the JSON envelope only.',
    );
    return buffer.toString();
  }

  static String repairPrompt({
    required String previousOutput,
    required List<String> errors,
  }) {
    return '''
Your previous JSON was invalid:
${errors.map((e) => '- $e').join('\n')}

Previous output:
$previousOutput

Return a corrected JSON envelope only. Ensure schema.\$schemaVersion is "1.0" and root is a valid node tree.
''';
  }

  static String _language(TargetPlatformKind platform) {
    switch (platform) {
      case TargetPlatformKind.flutter:
        return 'dart';
      case TargetPlatformKind.html:
        return 'html';
      case TargetPlatformKind.react:
        return 'jsx';
    }
  }
}
