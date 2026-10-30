import 'package:ai_ui_studio/ai/agent/response_parser.dart';
import 'package:ai_ui_studio/domain/entities/ui_component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses fenced JSON envelope with valid schema', () {
    const raw = '''
Here you go:
```json
{
  "componentName": "PromoCard",
  "description": "A promo card",
  "platform": "flutter",
  "schema": {
    "\$schemaVersion": "1.0",
    "root": {
      "type": "text",
      "props": { "data": "Hello" }
    }
  },
  "source": {
    "language": "dart",
    "files": [{ "path": "promo_card.dart", "content": "class PromoCard {}" }]
  },
  "tags": ["card"],
  "warnings": []
}
```
''';
    final envelope = ResponseParser.parse(raw);
    expect(envelope.componentName, 'PromoCard');
    expect(envelope.platform, TargetPlatformKind.flutter);
    expect(envelope.schemaValid, isTrue);
    expect(envelope.sourceFiles.single.path, 'promo_card.dart');
  });

  test('throws when neither schema nor source present', () {
    expect(
      () => ResponseParser.parse('{"componentName":"X","schema":null}'),
      throwsA(isA<ResponseParseException>()),
    );
  });
}
