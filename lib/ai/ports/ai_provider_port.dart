import 'package:ai_ui_studio/ai/ports/ai_models.dart';
import 'package:ai_ui_studio/domain/entities/ai_provider_config.dart';
import 'package:dio/dio.dart';

/// Contract for AI provider adapters. Implementations must never log API keys.
abstract class AiProviderPort {
  String get id;
  String get displayName;
  AiProviderType get providerType;

  bool get supportsStreaming;
  bool get supportsJsonObject;

  /// Static catalog used by the settings UI. Remote listing can be added later.
  List<AiModelInfo> get catalogModels;

  Stream<AiStreamChunk> streamChat(
    AiChatRequest request, {
    required String apiKey,
    required String baseUrl,
    CancelToken? cancelToken,
  });

  Future<AiChatResponse> chat(
    AiChatRequest request, {
    required String apiKey,
    required String baseUrl,
    CancelToken? cancelToken,
  });

  Future<AiConnectionTestResult> testConnection({
    required String apiKey,
    required String baseUrl,
    required String modelId,
    CancelToken? cancelToken,
  });
}
