import 'dart:convert';

import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';

/// Google Gemini generateContent / streamGenerateContent adapter.
class GeminiAdapter implements AiProviderPort {
  GeminiAdapter(this._dioFactory);

  final AiDioFactory _dioFactory;

  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  @override
  AiProviderType get providerType => AiProviderType.gemini;

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsJsonObject => true;

  @override
  List<AiModelInfo> get catalogModels => const [
        AiModelInfo(id: 'gemini-2.0-flash', displayName: 'Gemini 2.0 Flash'),
        AiModelInfo(id: 'gemini-1.5-flash', displayName: 'Gemini 1.5 Flash'),
        AiModelInfo(id: 'gemini-1.5-pro', displayName: 'Gemini 1.5 Pro'),
      ];

  Dio _client(String baseUrl) {
    return _dioFactory.create(
      baseUrl: baseUrl.isEmpty ? AppConstants.geminiDefaultBaseUrl : baseUrl,
    );
  }

  Map<String, dynamic> _body(AiChatRequest request) {
    final contents = <Map<String, dynamic>>[];
    String? system;
    for (final message in request.messages) {
      if (message.role == AiMessageRole.system) {
        system = message.content;
        continue;
      }
      contents.add({
        'role': message.role == AiMessageRole.assistant ? 'model' : 'user',
        'parts': [
          {'text': message.content},
        ],
      });
    }

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': request.temperature,
        if (request.maxTokens != null) 'maxOutputTokens': request.maxTokens,
        if (request.responseFormat == AiResponseFormat.jsonObject)
          'responseMimeType': 'application/json',
      },
    };
    if (system != null && system.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': system},
        ],
      };
    }
    return body;
  }

  String _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) return '';
    final content = candidates.first['content'] as Map<String, dynamic>? ?? {};
    final parts = content['parts'] as List<dynamic>? ?? [];
    return parts
        .whereType<Map>()
        .map((p) => p['text']?.toString() ?? '')
        .join();
  }

  @override
  Future<AiChatResponse> chat(
    AiChatRequest request, {
    required String apiKey,
    required String baseUrl,
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = _client(baseUrl);
      final response = await dio.post<Map<String, dynamic>>(
        'models/${request.model}:generateContent',
        queryParameters: {'key': apiKey},
        data: _body(request),
        cancelToken: cancelToken,
      );
      final data = response.data ?? {};
      final usage = data['usageMetadata'] as Map<String, dynamic>?;
      return AiChatResponse(
        text: _extractText(data),
        finishReason: (data['candidates'] is List &&
                (data['candidates'] as List).isNotEmpty)
            ? ((data['candidates'] as List).first['finishReason'] as String?)
            : null,
        promptTokens: usage?['promptTokenCount'] as int?,
        completionTokens: usage?['candidatesTokenCount'] as int?,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Stream<AiStreamChunk> streamChat(
    AiChatRequest request, {
    required String apiKey,
    required String baseUrl,
    CancelToken? cancelToken,
  }) async* {
    try {
      final dio = _client(baseUrl);
      final response = await dio.post<ResponseBody>(
        'models/${request.model}:streamGenerateContent',
        queryParameters: {
          'key': apiKey,
          'alt': 'sse',
        },
        data: _body(request),
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw ProviderFailure('Empty stream from Gemini.');
      }

      var buffer = '';
      await for (final bytes in stream) {
        buffer += utf8.decode(bytes, allowMalformed: true);
        final parts = buffer.split('\n');
        buffer = parts.removeLast();
        for (final line in parts) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
          final payload = trimmed.substring(5).trim();
          if (payload == '[DONE]') {
            yield const AiStreamChunk(finishReason: 'STOP');
            return;
          }
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final text = _extractText(json);
            final finish = (json['candidates'] is List &&
                    (json['candidates'] as List).isNotEmpty)
                ? ((json['candidates'] as List).first['finishReason']
                    as String?)
                : null;
            if (text.isNotEmpty || finish != null) {
              yield AiStreamChunk(deltaText: text, finishReason: finish);
            }
          } catch (_) {
            // Ignore partial SSE frames.
          }
        }
      }
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<AiConnectionTestResult> testConnection({
    required String apiKey,
    required String baseUrl,
    required String modelId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await chat(
        AiChatRequest(
          model: modelId,
          messages: const [
            AiChatMessage(role: AiMessageRole.user, content: 'Reply with OK'),
          ],
          temperature: 0,
          maxTokens: 16,
        ),
        apiKey: apiKey,
        baseUrl: baseUrl,
        cancelToken: cancelToken,
      );
      return AiConnectionTestResult(
        success: true,
        message: 'Connected. Sample reply: ${response.text.trim()}',
        modelId: modelId,
      );
    } catch (e) {
      return AiConnectionTestResult(
        success: false,
        message: e.toString(),
        modelId: modelId,
      );
    }
  }

  ProviderFailure _mapDio(DioException e) {
    if (e.type == DioExceptionType.cancel) {
      return ProviderFailure('Request cancelled.');
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    var detail = e.message ?? 'Network error';
    if (data is Map && data['error'] is Map) {
      detail = (data['error']['message'] as String?) ?? detail;
    }
    return ProviderFailure(
      status == null ? detail : 'HTTP $status: $detail',
      cause: e,
    );
  }
}
