import 'package:ai_ui_studio/ai/agent/response_parser.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses visual envelope with preview files', () {
    const raw = '''
```json
{
  "componentName": "PromoCard",
  "description": "A promo card",
  "platform": "visual",
  "schema": {
    "\$schemaVersion": "1.0",
    "root": {
      "type": "text",
      "props": { "data": "Hello" }
    }
  },
  "preview": {
    "files": [
      { "path": "preview/index.html", "content": "<div class='card'>Hello</div>" },
      { "path": "preview/styles.css", "content": ".card{padding:12px}" },
      { "path": "preview/script.js", "content": "" }
    ]
  },
  "tags": ["card"],
  "warnings": []
}
```
''';
    final envelope = ResponseParser.parse(raw);
    expect(envelope.componentName, 'PromoCard');
    expect(envelope.platform, TargetPlatformKind.visual);
    expect(envelope.schemaValid, isTrue);
    expect(envelope.hasHtmlPreview, isTrue);
    expect(
      envelope.sourceFiles.any((f) => f.path == 'preview/index.html'),
      isTrue,
    );
  });

  test('throws when neither schema nor source present', () {
    expect(
      () => ResponseParser.parse('{"componentName":"X","schema":null}'),
      throwsA(isA<ResponseParseException>()),
    );
  });
}
