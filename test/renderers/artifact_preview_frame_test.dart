import 'package:ai_ui_studio/renderers/preview_frame/artifact_preview_frame.dart';
import 'package:ai_ui_studio/renderers/flutter_renderer/widget_renderer.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('artifact frame wraps component like a ready element card',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArtifactPreviewFrame(
            caption: 'Try tapping',
            child: Icon(Icons.shopping_cart_outlined),
          ),
        ),
      ),
    );

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Try tapping'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets('SchemaPreview uses framed artifact by default', (tester) async {
    final document = UiSchemaValidator.parseOrThrow({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'badge',
        'props': {'icon': 'notifications', 'count': 2},
        'style': {'width': 44},
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SchemaPreview(document: document),
        ),
      ),
    );

    expect(find.text('Preview'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
  });
}
