import 'dart:convert';

import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/ports/ai_provider_port.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
import 'package:ai_ui_studio/core/errors/failures.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';

/// Anthropic Messages API adapter (provider-specific headers and payload).
class AnthropicAdapter implements AiProviderPort {
  AnthropicAdapter(this._dioFactory);

  final AiDioFactory _dioFactory;

  @override
  String get id => 'anthropic';

  @override
  String get displayName => 'Anthropic Claude';

  @override
  AiProviderType get providerType => AiProviderType.anthropic;

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsJsonObject => false;

  @override
  List<AiModelInfo> get catalogModels => const [
        AiModelInfo(
          id: 'claude-3-5-haiku-latest',
          displayName: 'Claude 3.5 Haiku',
        ),
        AiModelInfo(
          id: 'claude-3-5-sonnet-latest',
          displayName: 'Claude 3.5 Sonnet',
        ),
        AiModelInfo(
          id: 'claude-sonnet-4-0',
          displayName: 'Claude Sonnet 4',
        ),
      ];

  Dio _client(String baseUrl, String apiKey) {
    return _dioFactory.create(
      baseUrl:
          baseUrl.isEmpty ? AppConstants.anthropicDefaultBaseUrl : baseUrl,
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': AppConstants.anthropicApiVersion,
      },
    );
  }

  Map<String, dynamic> _body(AiChatRequest request, {required bool stream}) {
    String? system;
    final messages = <Map<String, dynamic>>[];
    for (final message in request.messages) {
      if (message.role == AiMessageRole.system) {
        system = message.content;
        continue;
      }
      messages.add({
        'role': message.role == AiMessageRole.assistant ? 'assistant' : 'user',
        'content': message.content,
      });
    }

    final body = <String, dynamic>{
      'model': request.model,
      'messages': messages,
      'max_tokens': request.maxTokens ?? 1024,
      'temperature': request.temperature,
      'stream': stream,
    };
    if (system != null && system.isNotEmpty) {
      body['system'] = system;
    }
    return body;
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
        'v1/messages',
        data: _body(request, stream: false),
        cancelToken: cancelToken,
      );
      final data = response.data ?? {};
      final content = data['content'] as List<dynamic>? ?? [];
      final text = content
          .whereType<Map>()
          .where((e) => e['type'] == 'text')
          .map((e) => e['text'] as String? ?? '')
          .join();
      final usage = data['usage'] as Map<String, dynamic>?;
      return AiChatResponse(
        text: text,
        finishReason: data['stop_reason'] as String?,
        promptTokens: usage?['input_tokens'] as int?,
        completionTokens: usage?['output_tokens'] as int?,
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
        'v1/messages',
        data: _body(request, stream: true),
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw ProviderFailure('Empty stream from Anthropic.');
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
            yield const AiStreamChunk(finishReason: 'end_turn');
            return;
          }
          final chunk = _parseEvent(payload);
          if (chunk != null) yield chunk;
        }
      }
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AiStreamChunk? _parseEvent(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final type = json['type'] as String?;
      if (type == 'content_block_delta') {
        final delta = json['delta'] as Map<String, dynamic>? ?? {};
        if (delta['type'] == 'text_delta') {
          return AiStreamChunk(deltaText: delta['text'] as String? ?? '');
        }
      }
      if (type == 'message_delta') {
        final delta = json['delta'] as Map<String, dynamic>? ?? {};
        return AiStreamChunk(
          finishReason: delta['stop_reason'] as String?,
        );
      }
      if (type == 'message_stop') {
        return const AiStreamChunk(finishReason: 'end_turn');
      }
      return null;
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
