import 'package:ai_ui_studio/core/utils/url_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts https by default', () {
    final result = UrlValidator.validate(
      'https://api.openai.com/v1/',
      allowInsecureHttp: false,
    );
    expect(result.isValid, isTrue);
    expect(result.isSecure, isTrue);
    expect(result.normalizedUrl, 'https://api.openai.com/v1');
  });

  test('rejects http when opt-in is off', () {
    final result = UrlValidator.validate(
      'http://localhost:1234/v1',
      allowInsecureHttp: false,
    );
    expect(result.isValid, isFalse);
    expect(result.message, contains('HTTP is blocked'));
  });

  test('allows http when opt-in is on', () {
    final result = UrlValidator.validate(
      'http://127.0.0.1:8080/v1',
      allowInsecureHttp: true,
    );
    expect(result.isValid, isTrue);
    expect(result.isSecure, isFalse);
    expect(result.message, contains('Warning'));
  });

  test('rejects empty and invalid urls', () {
    expect(
      UrlValidator.validate('', allowInsecureHttp: false).isValid,
      isFalse,
    );
    expect(
      UrlValidator.validate('not-a-url', allowInsecureHttp: false).isValid,
      isFalse,
    );
  });
}
