import 'package:ai_ui_studio/renderers/flutter_renderer/widget_renderer.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders nested card with button', (tester) async {
    final document = UiSchemaValidator.parseOrThrow({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'card',
        'children': [
          {
            'type': 'column',
            'children': [
              {
                'type': 'text',
                'props': {'data': 'Title'},
              },
              {
                'type': 'button',
                'props': {'label': 'Continue'},
              },
            ],
          },
        ],
      },
    });

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterWidgetRenderer(
            onAction: (_, __) => tapped = true,
          ).buildDocument(document),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    expect(tapped, isTrue);
  });

  testWidgets('shows error UI for invalid schema json', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const FlutterWidgetRenderer().buildFromJson({
            'root': {'type': 'text'},
          }),
        ),
      ),
    );
    expect(find.textContaining('Schema error'), findsOneWidget);
  });
}
