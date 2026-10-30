import 'package:ai_ui_studio/core/logging/redacting_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RedactingLogger logger;

  setUp(() {
    logger = RedactingLogger();
  });

  test('redacts bearer tokens', () {
    final output = logger.redact('Authorization: Bearer sk-abc123secret');
    expect(output, contains('***REDACTED***'));
    expect(output, isNot(contains('sk-abc123secret')));
  });

  test('redacts x-api-key headers', () {
    final output = logger.redact('x-api-key: anthropic-secret-key');
    expect(output, contains('***REDACTED***'));
    expect(output, isNot(contains('anthropic-secret-key')));
  });

  test('redacts OpenAI-looking keys in free text', () {
    final output = logger.redact('using key sk-proj-ABCDEFGHijklmnop');
    expect(output, contains('***REDACTED***'));
    expect(output, isNot(contains('sk-proj-ABCDEFGHijklmnop')));
  });

  test('redacts sensitive header map values', () {
    final headers = logger.redactHeaders({
      'Authorization': 'Bearer secret',
      'x-api-key': 'secret2',
      'Content-Type': 'application/json',
    });
    expect(headers['Authorization'], '***REDACTED***');
    expect(headers['x-api-key'], '***REDACTED***');
    expect(headers['Content-Type'], 'application/json');
  });
}
