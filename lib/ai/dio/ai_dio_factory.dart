import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/logging/redacting_logger.dart';
import 'package:dio/dio.dart';

class AiDioFactory {
  AiDioFactory(this._logger, {HttpClientAdapter? httpClientAdapter})
      : _httpClientAdapter = httpClientAdapter;

  final RedactingLogger _logger;
  final HttpClientAdapter? _httpClientAdapter;

  Dio create({
    required String baseUrl,
    Map<String, String>? headers,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
        connectTimeout: AppConstants.httpConnectTimeout,
        receiveTimeout: AppConstants.httpReceiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        responseType: ResponseType.json,
      ),
    );
    final adapter = _httpClientAdapter;
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d(
            'HTTP ${options.method} ${options.uri} headers=${_logger.redactHeaders(options.headers)}',
          );
          handler.next(options);
        },
        onError: (error, handler) {
          _logger.e(
            'HTTP error ${error.requestOptions.method} ${error.requestOptions.uri}: ${error.message}',
            error: error,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
