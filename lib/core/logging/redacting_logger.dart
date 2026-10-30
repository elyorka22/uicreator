import 'package:logger/logger.dart';

/// Logger that strips API keys and auth headers from messages.
class RedactingLogger {
  RedactingLogger({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 4,
                lineLength: 100,
              ),
            );

  final Logger _logger;

  static final List<RegExp> _patterns = [
    RegExp(r'(Authorization\s*[:=]\s*Bearer\s+)(\S+)', caseSensitive: false),
    RegExp(r'(x-api-key\s*[:=]\s*)(\S+)', caseSensitive: false),
    RegExp(r'(api[_-]?key\s*[:=]\s*)(\S+)', caseSensitive: false),
    RegExp(r'(sk-[A-Za-z0-9_\-]{8,})'),
    RegExp(r'(key=)([^&\s]+)', caseSensitive: false),
  ];

  String redact(String input) {
    var output = input;
    for (final pattern in _patterns) {
      output = output.replaceAllMapped(pattern, (match) {
        if (match.groupCount >= 2) {
          return '${match.group(1)}***REDACTED***';
        }
        return '***REDACTED***';
      });
    }
    return output;
  }

  Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
    final redacted = <String, dynamic>{};
    headers.forEach((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'authorization' ||
          lower == 'x-api-key' ||
          lower == 'api-key' ||
          lower.contains('api_key')) {
        redacted[key] = '***REDACTED***';
      } else {
        redacted[key] = value;
      }
    });
    return redacted;
  }

  void d(String message) => _logger.d(redact(message));
  void i(String message) => _logger.i(redact(message));
  void w(String message) => _logger.w(redact(message));
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(
      redact(message),
      error: error == null ? null : redact(error.toString()),
      stackTrace: stackTrace,
    );
  }
}
