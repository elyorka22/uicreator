import 'package:ai_ui_studio/renderers/flutter_renderer/widget_renderer.dart';
import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders stacked notification badge overlay', (tester) async {
    final document = UiSchemaValidator.parseOrThrow({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'sizedBox',
        'style': {'width': 44, 'height': 44},
        'children': [
          {
            'type': 'stack',
            'style': {'alignment': 'center'},
            'children': [
              {
                'type': 'icon',
                'props': {'name': 'notifications'},
                'style': {'width': 28, 'color': '#FF1C1C24'},
              },
              {
                'type': 'positioned',
                'style': {'top': 3, 'right': 3},
                'children': [
                  {
                    'type': 'container',
                    'style': {
                      'padding': {'horizontal': 4, 'vertical': 2},
                      'decoration': {
                        'color': '#FFFF3B5C',
                        'borderRadius': 10,
                      },
                    },
                    'children': [
                      {
                        'type': 'text',
                        'props': {'data': '3'},
                        'style': {
                          'textStyle': {
                            'color': '#FFFFFFFF',
                            'fontSize': 10,
                            'fontWeight': 'w700',
                          },
                        },
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const FlutterWidgetRenderer().buildDocument(document),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(Stack), findsWidgets);
    expect(find.byType(Positioned), findsOneWidget);
  });
}
