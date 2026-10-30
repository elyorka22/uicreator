import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_ui_studio/ai/dio/ai_dio_factory.dart';
import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/ai/providers/anthropic_adapter.dart';
import 'package:ai_ui_studio/core/constants/app_constants.dart';
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
  test('chat maps Anthropic Messages response and headers', () async {
    final fake = _FakeAdapter((options) async {
      expect(options.path, 'v1/messages');
      expect(options.headers['x-api-key'], 'anth-key');
      expect(
        options.headers['anthropic-version'],
        AppConstants.anthropicApiVersion,
      );
      final data = options.data as Map<String, dynamic>;
      expect(data['stream'], isFalse);
      expect(data['system'], 'Be brief');
      return ResponseBody.fromString(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': 'OK'},
          ],
          'stop_reason': 'end_turn',
          'usage': {'input_tokens': 4, 'output_tokens': 1},
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final adapter = AnthropicAdapter(
      AiDioFactory(RedactingLogger(), httpClientAdapter: fake),
    );

    final response = await adapter.chat(
      const AiChatRequest(
        model: 'claude-3-5-haiku-latest',
        messages: [
          AiChatMessage(role: AiMessageRole.system, content: 'Be brief'),
          AiChatMessage(role: AiMessageRole.user, content: 'Hi'),
        ],
      ),
      apiKey: 'anth-key',
      baseUrl: AppConstants.anthropicDefaultBaseUrl,
    );

    expect(response.text, 'OK');
    expect(response.finishReason, 'end_turn');
  });
}
