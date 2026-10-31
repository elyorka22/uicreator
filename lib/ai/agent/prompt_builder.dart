import 'package:ai_ui_studio/domain/entities/ui_component.dart';

class PromptBuilder {
  static String systemPrompt(TargetPlatformKind platform) {
    final platformLabel = platform.wireName;
    return '''
You are a senior mobile UI engineer working inside AI UI Studio.
Your job is to generate PRODUCTION-QUALITY reusable UI components — not toy demos.

Return ONLY one JSON object (no markdown fences, no commentary):
{
  "componentName": "PascalCaseName",
  "description": "short description",
  "platform": "$platformLabel",
  "schema": { "\$schemaVersion": "1.0", "root": { } },
  "source": {
    "language": "${_language(platform)}",
    "files": [{ "path": "filename.ext", "content": "..." }]
  },
  "tags": ["tag"],
  "warnings": []
}

========================
QUALITY BAR (mandatory)
========================
- Output must look like something shippable in a real app.
- Prefer a focused reusable component (widget/component), not a full marketing page unless asked.
- Use real spacing, typography hierarchy, colors, border radius, shadows when appropriate.
- Support props/parameters in source (e.g. unreadCount, onTap, color, size).
- Avoid childish / placeholder layouts like: big title + outlined box + caption text explaining the UI.
- Do NOT invent fake "Уведомления / 3 новых уведомления" demo chrome unless the user asked for a full screen.
- Icons should be meaningful (e.g. notifications_rounded). Badges must overlay the icon (Stack + Positioned), not sit as sibling text in a row/column.

========================
UNIVERSAL UI SCHEMA
========================
- \$schemaVersion must be "1.0".
- Supported types: container, text, button, image, icon, row, column, stack, positioned, card, textField, checkbox, switch, divider, padding, scrollView, sizedBox, spacer, center, expanded, flexible, gestureDetector.
- Colors: #RRGGBB or #AARRGGBB.
- text => props.data; button => props.label; image => props.url; icon => props.name.
- For overlays (notification badge, avatar status): use type "stack" with a child type "positioned" (style.top/right/left/bottom).
- Schema is a BEST-EFFORT preview. If animations/custom painters cannot be expressed, still approximate visually in schema AND put the full implementation in source.
- actions.onPressed may use {"type":"previewToast","message":"..."}.

Example schema fragment for a notification bell with badge:
{
  "type": "sizedBox",
  "style": { "width": 44, "height": 44 },
  "children": [{
    "type": "stack",
    "style": { "alignment": "center" },
    "children": [
      { "type": "icon", "props": { "name": "notifications" }, "style": { "width": 28, "color": "#FF1C1C24" } },
      {
        "type": "positioned",
        "style": { "top": 3, "right": 3 },
        "children": [{
          "type": "container",
          "style": {
            "padding": { "horizontal": 4, "vertical": 2 },
            "decoration": { "color": "#FFFF3B5C", "borderRadius": 10, "border": { "color": "#FFF5F5F7", "width": 2 } }
          },
          "children": [{
            "type": "text",
            "props": { "data": "3" },
            "style": { "textStyle": { "color": "#FFFFFFFF", "fontSize": 10, "fontWeight": "w700" } }
          }]
        }]
      }
    ]
  }]
}

========================
PLATFORM SOURCE RULES
========================
${_platformSourceRules(platform)}

If the UI cannot be represented by schema, set "schema" to null and add warning "source_only", but ALWAYS provide excellent source.
Never include API keys or secrets.
''';
  }

  static String _platformSourceRules(TargetPlatformKind platform) {
    switch (platform) {
      case TargetPlatformKind.flutter:
        return '''
Flutter / Dart source requirements:
- Emit a reusable widget file (StatelessWidget OR StatefulWidget when animation/state is needed).
- Include constructor parameters, const where possible, clear docs.
- Use Material 3 idioms: Icon, Stack, Positioned, AnimatedScale/AnimatedBuilder when useful.
- For notification bells: shake/ring animation when unreadCount > 0, hide badge at 0, respect MediaQuery.disableAnimations, Semantics label, hit target ~44px.
- Include a small private demo/usage snippet ONLY as a comment or a separate optional demo widget — do not make the root preview a title+caption page.
- Code must compile as a standalone widget file (import material.dart; no app-specific packages).
''';
      case TargetPlatformKind.html:
        return '''
HTML/CSS/JS:
- Clean semantic HTML, modern CSS (flex/grid), accessible controls.
- Separate files when useful: index.html, styles.css, script.js.
''';
      case TargetPlatformKind.react:
        return '''
React / JSX:
- Functional component with props, readable JSX, minimal dependencies.
- Export default component.
''';
    }
  }

  static String userPrompt({
    required String description,
    required TargetPlatformKind platform,
    String? regenerateHint,
  }) {
    final buffer = StringBuffer()
      ..writeln('Target platform: ${platform.wireName}')
      ..writeln('User request:')
      ..writeln(description.trim())
      ..writeln()
      ..writeln(
        'Deliver a serious, production-quality component. '
        'Prioritize excellent source code. Schema preview must visually resemble the real component '
        '(use stack/positioned for badges/overlays). Avoid toy demo layouts.',
      );
    if (regenerateHint != null && regenerateHint.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Regeneration notes:')
        ..writeln(regenerateHint.trim());
    }
    buffer.writeln('\nRespond with the JSON envelope only.');
    return buffer.toString();
  }

  /// Iterative edit: keep the existing component and apply a change request.
  static String refineUserPrompt({
    required String changeRequest,
    required TargetPlatformKind platform,
    required String componentName,
    String? originalPrompt,
    String? currentSchemaJson,
    List<SourceFile> currentSourceFiles = const [],
  }) {
    final buffer = StringBuffer()
      ..writeln('Target platform: ${platform.wireName}')
      ..writeln('Task: REFINE an existing component. Do not start from scratch.')
      ..writeln('Component name: $componentName');
    if (originalPrompt != null && originalPrompt.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Original user intent:')
        ..writeln(originalPrompt.trim());
    }
    buffer
      ..writeln()
      ..writeln('Requested changes (apply these carefully):')
      ..writeln(changeRequest.trim())
      ..writeln()
      ..writeln(
        'Rules for refine:\n'
        '- Preserve what already works unless the change request overrides it.\n'
        '- Update BOTH schema (preview) and source files.\n'
        '- Keep production quality; no toy demo chrome.\n'
        '- Keep the same componentName unless renaming was requested.',
      );

    if (currentSchemaJson != null && currentSchemaJson.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Current schema JSON:')
        ..writeln(_truncate(currentSchemaJson.trim(), 6000));
    }

    if (currentSourceFiles.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Current source files:');
      for (final file in currentSourceFiles) {
        buffer
          ..writeln('--- ${file.path} ---')
          ..writeln(_truncate(file.content, 8000));
      }
    }

    buffer.writeln('\nRespond with the full updated JSON envelope only.');
    return buffer.toString();
  }

  static String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars)}\n… [truncated]';
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

Return a corrected JSON envelope only. Keep production-quality source. Ensure schema.\$schemaVersion is "1.0" when schema is present.
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
