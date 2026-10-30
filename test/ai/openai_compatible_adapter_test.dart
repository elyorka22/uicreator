import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/providers/openai_compatible_adapter.dart';
import 'package:ai_ui_studio/core/logging/redacting_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) {
    return handler(options);
  }
}

void main() {
  test('chat maps OpenAI Chat Completions response', () async {
    final fake = _FakeAdapter((options) async {
      expect(options.path, 'chat/completions');
      expect(options.headers['Authorization'], 'Bearer test-key');
      final data = options.data as Map<String, dynamic>;
      expect(data['stream'], isFalse);
      expect(data['model'], 'gpt-4o-mini');
      return ResponseBody.fromString(
        jsonEncode({
          'choices': [
            {
              'message': {'content': 'hello from model'},
              'finish_reason': 'stop',
            }
          ],
          'usage': {'prompt_tokens': 3, 'completion_tokens': 2},
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final adapter = OpenAiCompatibleAdapter(
      AiDioFactory(RedactingLogger(), httpClientAdapter: fake),
    );

    final response = await adapter.chat(
      const AiChatRequest(
        model: 'gpt-4o-mini',
        messages: [
          AiChatMessage(role: AiMessageRole.user, content: 'hi'),
        ],
      ),
      apiKey: 'test-key',
      baseUrl: 'https://example.com/v1',
    );

    expect(response.text, 'hello from model');
    expect(response.finishReason, 'stop');
    expect(response.promptTokens, 3);
    expect(response.completionTokens, 2);
  });

  test('streamChat parses SSE data chunks', () async {
    final payload = [
      'data: {"choices":[{"delta":{"content":"Hel"},"finish_reason":null}]}',
      '',
      'data: {"choices":[{"delta":{"content":"lo"},"finish_reason":null}]}',
      '',
      'data: [DONE]',
      '',
    ].join('\n');

    final fake = _FakeAdapter((options) async {
      expect(options.path, 'chat/completions');
      final data = options.data as Map<String, dynamic>;
      expect(data['stream'], isTrue);
      return ResponseBody(
        Stream<Uint8List>.fromIterable([Uint8List.fromList(utf8.encode(payload))]),
        200,
        headers: {
          Headers.contentTypeHeader: ['text/event-stream'],
        },
      );
    });

    final adapter = OpenAiCompatibleAdapter(
      AiDioFactory(RedactingLogger(), httpClientAdapter: fake),
    );

    final chunks = await adapter
        .streamChat(
          const AiChatRequest(
            model: 'gpt-4o-mini',
            messages: [
              AiChatMessage(role: AiMessageRole.user, content: 'hi'),
            ],
          ),
          apiKey: 'test-key',
          baseUrl: 'https://example.com/v1',
        )
        .toList();

    final text = chunks.map((c) => c.deltaText).join();
    expect(text, 'Hello');
    expect(chunks.last.finishReason, 'stop');
  });
}
