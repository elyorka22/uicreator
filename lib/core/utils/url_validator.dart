import 'package:ai_ui_studio/core/errors/failures.dart';

class UrlValidationResult {
  const UrlValidationResult({
    required this.isValid,
    required this.isSecure,
    this.normalizedUrl,
    this.message,
  });

  final bool isValid;
  final bool isSecure;
  final String? normalizedUrl;
  final String? message;
}

class UrlValidator {
  /// Validates a provider base URL.
  /// Non-HTTPS URLs are only allowed when [allowInsecureHttp] is true.
  static UrlValidationResult validate(
    String raw, {
    required bool allowInsecureHttp,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const UrlValidationResult(
        isValid: false,
        isSecure: false,
        message: 'Base URL is required.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return const UrlValidationResult(
        isValid: false,
        isSecure: false,
        message: 'Enter a valid absolute URL with host.',
      );
    }

    final scheme = uri.scheme.toLowerCase();
    final isHttps = scheme == 'https';
    final isHttp = scheme == 'http';

    if (!isHttps && !isHttp) {
      return const UrlValidationResult(
        isValid: false,
        isSecure: false,
        message: 'Only http and https URLs are supported.',
      );
    }

    if (isHttp && !allowInsecureHttp) {
      return const UrlValidationResult(
        isValid: false,
        isSecure: false,
        message:
            'HTTP is blocked by default. Enable “Allow insecure HTTP” in Settings to use local gateways.',
      );
    }

    final normalized = uri.replace(path: uri.path.replaceAll(RegExp(r'/+$'), '')).toString();
    return UrlValidationResult(
      isValid: true,
      isSecure: isHttps,
      normalizedUrl: normalized,
      message: isHttp
          ? 'Warning: HTTP sends API keys in cleartext. Use only on trusted local networks.'
          : null,
    );
  }

  static void ensureValid(String raw, {required bool allowInsecureHttp}) {
    final result = validate(raw, allowInsecureHttp: allowInsecureHttp);
    if (!result.isValid) {
      throw ValidationFailure(result.message ?? 'Invalid URL');
    }
  }
}
