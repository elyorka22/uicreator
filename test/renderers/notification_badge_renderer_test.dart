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

  testWidgets('badge type stays compact and tappable with animation',
      (tester) async {
    final document = UiSchemaValidator.parseOrThrow({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'badge',
        'props': {
          'icon': 'notifications',
          'count': 3,
          'max': 9,
          'badgeColor': '#FFFF3B5C',
          'animation': 'shake',
        },
        'style': {'width': 44, 'color': '#FF1C1C24', 'animation': 'shake'},
        'actions': {
          'onPressed': {'type': 'previewToast', 'message': 'Open'},
        },
      },
    });

    String? action;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterWidgetRenderer(
            onAction: (type, _) => action = type,
          ).buildDocument(document),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    final size = tester.getSize(find.byType(SizedBox).first);
    expect(size.width, lessThanOrEqualTo(48));
    expect(size.height, lessThanOrEqualTo(48));

    await tester.tap(find.byIcon(Icons.notifications_rounded));
    expect(action, 'previewToast');
  });

  testWidgets('unbounded stack with positioned stays ~48 wide', (tester) async {
    final document = UiSchemaValidator.parseOrThrow({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'stack',
        'children': [
          {
            'type': 'icon',
            'props': {'name': 'notifications'},
            'style': {'width': 28},
          },
          {
            'type': 'positioned',
            'style': {'top': 0, 'right': 0},
            'children': [
              {
                'type': 'text',
                'props': {'data': '3'},
              },
            ],
          },
        ],
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: const FlutterWidgetRenderer().buildDocument(document),
          ),
        ),
      ),
    );

    final badgeCenter = tester.getCenter(find.text('3'));
    final iconCenter =
        tester.getCenter(find.byIcon(Icons.notifications_rounded));
    // Badge must sit near the icon — not at the far right of a 400px row.
    expect((badgeCenter.dx - iconCenter.dx).abs(), lessThan(40),
        reason: 'icon=$iconCenter badge=$badgeCenter');
  });
}
