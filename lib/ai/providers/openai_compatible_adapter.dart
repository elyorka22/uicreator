import 'dart:async';
import 'dart:convert';

import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';

/// OpenAI Chat Completions adapter. Also works with OpenAI-compatible gateways.
/// Extensible later for the Responses API without changing call sites.
class OpenAiCompatibleAdapter implements AiProviderPort {
  OpenAiCompatibleAdapter(this._dioFactory);

  final AiDioFactory _dioFactory;

  @override
  String get id => 'openai_compatible';

  @override
  String get displayName => 'OpenAI Compatible';

  @override
  AiProviderType get providerType => AiProviderType.openaiCompatible;

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsJsonObject => true;

  @override
  List<AiModelInfo> get catalogModels => const [
        AiModelInfo(id: 'gpt-4o-mini', displayName: 'GPT-4o mini'),
        AiModelInfo(id: 'gpt-4o', displayName: 'GPT-4o'),
        AiModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 mini'),
        AiModelInfo(id: 'gpt-4.1', displayName: 'GPT-4.1'),
      ];

  Map<String, dynamic> _body(AiChatRequest request, {required bool stream}) {
    final body = <String, dynamic>{
      'model': request.model,
      'messages': request.messages
          .map(
            (m) => {
              'role': m.role.name,
              'content': m.content,
            },
          )
          .toList(),
      'temperature': request.temperature,
      'stream': stream,
    };
    if (request.maxTokens != null) {
      body['max_tokens'] = request.maxTokens;
    }
    if (request.responseFormat == AiResponseFormat.jsonObject) {
      body['response_format'] = {'type': 'json_object'};
    }
    return body;
  }

  Dio _client(String baseUrl, String apiKey) {
    return _dioFactory.create(
      baseUrl: baseUrl.isEmpty ? AppConstants.openAiDefaultBaseUrl : baseUrl,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
  }

  @override
  Future<AiChatResponse> chat(
    AiChatRequest request, {
    required String apiKey,
    required String baseUrl,
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = _client(baseUrl, apiKey);
      final response = await dio.post<Map<String, dynamic>>(
        'chat/completions',
        data: _body(request, stream: false),
        cancelToken: cancelToken,
      );
      final data = response.data ?? {};
      final choices = data['choices'] as List<dynamic>? ?? [];
      if (choices.isEmpty) {
        throw ProviderFailure('Provider returned no choices.');
      }
      final message = choices.first['message'] as Map<String, dynamic>? ?? {};
      final usage = data['usage'] as Map<String, dynamic>?;
      return AiChatResponse(
        text: (message['content'] as String?) ?? '',
        finishReason: choices.first['finish_reason'] as String?,
        promptTokens: usage?['prompt_tokens'] as int?,
        completionTokens: usage?['completion_tokens'] as int?,
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
      final dio = _client(baseUrl, apiKey);
      final response = await dio.post<ResponseBody>(
        'chat/completions',
        data: _body(request, stream: true),
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw ProviderFailure('Empty stream from provider.');
      }

      var buffer = '';
      await for (final bytes in stream) {
        buffer += utf8.decode(bytes, allowMalformed: true);
        final parts = buffer.split('\n');
        buffer = parts.removeLast();
        for (final line in parts) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (!trimmed.startsWith('data:')) continue;
          final payload = trimmed.substring(5).trim();
          if (payload == '[DONE]') {
            yield const AiStreamChunk(finishReason: 'stop');
            return;
          }
          final chunk = _parseSseChunk(payload);
          if (chunk != null) {
            yield chunk;
          }
        }
      }
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AiStreamChunk? _parseSseChunk(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>? ?? [];
      if (choices.isEmpty) return null;
      final choice = choices.first as Map<String, dynamic>;
      final delta = choice['delta'] as Map<String, dynamic>? ?? {};
      return AiStreamChunk(
        deltaText: (delta['content'] as String?) ?? '',
        finishReason: choice['finish_reason'] as String?,
      );
    } catch (_) {
      return null;
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
            AiChatMessage(
              role: AiMessageRole.user,
              content: 'Reply with OK',
            ),
          ],
          temperature: 0,
          maxTokens: 8,
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
    } else if (data is String && data.isNotEmpty) {
      detail = data;
    }
    return ProviderFailure(
      status == null ? detail : 'HTTP $status: $detail',
      cause: e,
    );
  }
}
