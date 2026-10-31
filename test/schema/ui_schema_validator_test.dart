import 'package:ai_ui_studio/schema/ui_schema_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts nested valid schema', () {
    final result = UiSchemaValidator.validate({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'card',
        'props': {'elevation': 2},
        'style': {'padding': {'all': 12}},
        'children': [
          {
            'type': 'column',
            'style': {'gap': 8},
            'children': [
              {
                'type': 'text',
                'props': {'data': 'Hello'},
              },
              {
                'type': 'button',
                'props': {'label': 'Go'},
              },
            ],
          },
        ],
      },
    });
    expect(result.isValid, isTrue);
    expect(result.document!.nodeCount, 4);
  });

  test('rejects missing version and invalid nodes', () {
    final result = UiSchemaValidator.validate({
      'root': {
        'type': 'text',
        'props': {},
      },
    });
    expect(result.isValid, isFalse);
    expect(result.errors.join(' '), contains('\$schemaVersion'));
    expect(result.errors.join(' '), contains('props.data'));
  });

  test('rejects unsupported types', () {
    final result = UiSchemaValidator.validate({
      '\$schemaVersion': '1.0',
      'root': {'type': 'magicWidget'},
    });
    expect(result.isValid, isFalse);
    expect(result.errors.join(' '), contains('unsupported type'));
  });

  test('accepts stack with positioned badge', () {
    final result = UiSchemaValidator.validate({
      '\$schemaVersion': '1.0',
      'root': {
        'type': 'stack',
        'children': [
          {
            'type': 'icon',
            'props': {'name': 'notifications'},
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
    expect(result.isValid, isTrue);
  });
}
