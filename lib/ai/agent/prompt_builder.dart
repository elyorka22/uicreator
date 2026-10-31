import 'package:ai_ui_studio/domain/entities/ui_component.dart';

class PromptBuilder {
  /// Visual-first generation: plain-language → beautiful HTML preview (+ schema).
  /// Export platform (Dart/HTML/React) is chosen later.
  static String visualSystemPrompt() {
    return '''
You are a senior product UI designer/engineer inside AI UI Studio.
Users describe UI in plain language. You create a BEAUTIFUL, interactive component
they can see and refine BEFORE choosing an export platform (Flutter/HTML/React).

Return ONLY one JSON object (no markdown fences, no commentary):
{
  "componentName": "PascalCaseName",
  "description": "short description",
  "platform": "visual",
  "schema": { "\$schemaVersion": "1.0", "root": { } },
  "preview": {
    "files": [
      { "path": "preview/index.html", "content": "..." },
      { "path": "preview/styles.css", "content": "..." },
      { "path": "preview/script.js", "content": "..." }
    ]
  },
  "tags": ["tag"],
  "warnings": []
}

========================
VISUAL PREVIEW (mandatory, highest priority)
========================
- preview/index.html + styles.css + script.js are the LIVE preview the user sees.
- Make it look like a polished ready-to-ship UI element (Claude-artifact quality).
- Include real micro-interactions: hover/press scale, badge shake, ripple, counter morph, soft shadows.
- Self-contained: no external CDNs, no remote fonts required (system fonts OK).
- Root content is THE COMPONENT only (fits inside a rounded preview card) — not a full marketing page unless asked.
- Use accessible controls (button/aria), 44px hit targets where relevant.
- Prefer one focused component (bell, cart button, product card, nav pill, etc.).

========================
UNIVERSAL UI SCHEMA (secondary fallback)
========================
- \$schemaVersion must be "1.0" when schema is present.
- Supported types: container, text, button, image, icon, badge, row, column, stack, positioned, card, textField, checkbox, switch, divider, padding, scrollView, sizedBox, spacer, center, expanded, flexible, gestureDetector.
- Prefer type "badge" for notification bells with animation shake|pulse|bounce and actions.onPressed.
- Schema is best-effort; HTML preview is the source of visual truth.

========================
QUALITY BAR
========================
- Ship-quality visuals, not toy demos.
- No childish title+caption explainer chrome unless requested.
- Never include API keys or secrets.
''';
  }

  /// Convert an existing visual component into exportable source for one platform.
  static String exportSystemPrompt(TargetPlatformKind platform) {
    assert(platform.isExportTarget);
    return '''
You convert an AI UI Studio visual component into production ${platform.wireName} source.

Return ONLY one JSON object:
{
  "componentName": "PascalCaseName",
  "description": "short description",
  "platform": "${platform.wireName}",
  "schema": { "\$schemaVersion": "1.0", "root": { } },
  "preview": {
    "files": [
      { "path": "preview/index.html", "content": "..." },
      { "path": "preview/styles.css", "content": "..." },
      { "path": "preview/script.js", "content": "..." }
    ]
  },
  "source": {
    "language": "${_language(platform)}",
    "files": [{ "path": "filename.ext", "content": "..." }]
  },
  "tags": ["tag"],
  "warnings": []
}

Keep/improve the HTML preview so Studio still looks good.
${_platformSourceRules(platform)}
Never include API keys or secrets.
''';
  }

  /// Legacy/platform-specific system prompt (export convert + older flows).
  static String systemPrompt(TargetPlatformKind platform) {
    if (platform == TargetPlatformKind.visual) {
      return visualSystemPrompt();
    }
    return exportSystemPrompt(platform);
  }

  static String _platformSourceRules(TargetPlatformKind platform) {
    switch (platform) {
      case TargetPlatformKind.visual:
        return 'Provide excellent HTML preview files under preview/.';
      case TargetPlatformKind.flutter:
        return '''
Flutter / Dart source requirements:
- Emit a reusable widget file (StatelessWidget OR StatefulWidget when animation/state is needed).
- Include constructor parameters, const where possible, clear docs.
- Use Material 3 idioms; animations should match the HTML preview intent.
- Code must compile as a standalone widget file (import material.dart; no app-specific packages).
''';
      case TargetPlatformKind.html:
        return '''
HTML/CSS/JS export:
- Clean semantic HTML, modern CSS, accessible controls.
- You may promote preview/* into top-level index.html, styles.css, script.js for export.
''';
      case TargetPlatformKind.react:
        return '''
React / JSX:
- Functional component with props, readable JSX, minimal dependencies.
- Export default component. Match preview visuals/interactions as closely as practical.
''';
    }
  }

  static String visualUserPrompt({
    required String description,
    String? regenerateHint,
  }) {
    final buffer = StringBuffer()
      ..writeln('Create a beautiful interactive UI component from this request:')
      ..writeln(description.trim())
      ..writeln()
      ..writeln(
        'Platform will be chosen later at export. '
        'Right now prioritize stunning HTML preview (preview/*) the user can click and refine. '
        'Also include a reasonable Universal UI Schema. Avoid toy demo layouts.',
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

  static String userPrompt({
    required String description,
    required TargetPlatformKind platform,
    String? regenerateHint,
  }) {
    if (platform == TargetPlatformKind.visual) {
      return visualUserPrompt(
        description: description,
        regenerateHint: regenerateHint,
      );
    }
    final buffer = StringBuffer()
      ..writeln('Target export platform: ${platform.wireName}')
      ..writeln('User request:')
      ..writeln(description.trim())
      ..writeln()
      ..writeln(
        'Deliver production-quality ${platform.wireName} source AND keep a polished HTML preview under preview/. '
        'Avoid toy demo layouts.',
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

  static String refineUserPrompt({
    required String changeRequest,
    required TargetPlatformKind platform,
    required String componentName,
    String? originalPrompt,
    String? currentSchemaJson,
    List<SourceFile> currentSourceFiles = const [],
  }) {
    final buffer = StringBuffer()
      ..writeln('Task: REFINE an existing visual UI component. Do not start from scratch.')
      ..writeln('Component name: $componentName')
      ..writeln('Current mode: ${platform.wireName}');
    if (originalPrompt != null && originalPrompt.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Original user intent:')
        ..writeln(originalPrompt.trim());
    }
    buffer
      ..writeln()
      ..writeln('Requested changes (apply carefully):')
      ..writeln(changeRequest.trim())
      ..writeln()
      ..writeln(
        'Rules for refine:\n'
        '- Update HTML preview files (preview/*) so the live Studio preview changes.\n'
        '- Update schema when possible.\n'
        '- Preserve export source files if present, unless the change requires updating them.\n'
        '- Keep production quality; platform export is chosen later unless already set.\n'
        '- Keep platform as "visual" unless the component already targets a specific export platform.\n'
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
      buffer.writeln('Current files:');
      for (final file in currentSourceFiles) {
        buffer
          ..writeln('--- ${file.path} ---')
          ..writeln(_truncate(file.content, 8000));
      }
    }

    buffer.writeln('\nRespond with the full updated JSON envelope only.');
    return buffer.toString();
  }

  static String exportConvertUserPrompt({
    required TargetPlatformKind target,
    required String componentName,
    String? originalPrompt,
    String? description,
    String? currentSchemaJson,
    List<SourceFile> currentSourceFiles = const [],
  }) {
    final buffer = StringBuffer()
      ..writeln('Convert this Studio component for EXPORT as ${target.wireName}.')
      ..writeln('Component name: $componentName');
    if (description != null && description.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Description:')
        ..writeln(description.trim());
    }
    if (originalPrompt != null && originalPrompt.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Original prompt:')
        ..writeln(originalPrompt.trim());
    }
    buffer
      ..writeln()
      ..writeln(
        'Produce excellent ${target.wireName} source files that match the HTML preview visuals/interactions. '
        'Keep preview/* so Studio preview still works. Set platform to "${target.wireName}".',
      );

    if (currentSchemaJson != null && currentSchemaJson.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Current schema JSON:')
        ..writeln(_truncate(currentSchemaJson.trim(), 5000));
    }
    if (currentSourceFiles.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Current files:');
      for (final file in currentSourceFiles) {
        buffer
          ..writeln('--- ${file.path} ---')
          ..writeln(_truncate(file.content, 7000));
      }
    }
    buffer.writeln('\nRespond with the JSON envelope only.');
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

Return a corrected JSON envelope only. Prefer valid preview/* HTML files. Ensure schema.\$schemaVersion is "1.0" when schema is present.
''';
  }

  static String _language(TargetPlatformKind platform) {
    switch (platform) {
      case TargetPlatformKind.visual:
      case TargetPlatformKind.html:
        return 'html';
      case TargetPlatformKind.flutter:
        return 'dart';
      case TargetPlatformKind.react:
        return 'jsx';
    }
  }
}
