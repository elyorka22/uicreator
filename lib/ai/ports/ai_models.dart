import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_models.freezed.dart';
part 'ai_models.g.dart';

enum AiMessageRole { system, user, assistant }

enum AiResponseFormat { text, jsonObject }

@freezed
class AiModelInfo with _$AiModelInfo {
  const factory AiModelInfo({
    required String id,
    required String displayName,
    String? description,
  }) = _AiModelInfo;

  factory AiModelInfo.fromJson(Map<String, dynamic> json) =>
      _$AiModelInfoFromJson(json);
}

@freezed
class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    required AiMessageRole role,
    required String content,
  }) = _AiChatMessage;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);
}

@freezed
class AiChatRequest with _$AiChatRequest {
  const factory AiChatRequest({
    required String model,
    required List<AiChatMessage> messages,
    @Default(0.7) double temperature,
    int? maxTokens,
    @Default(AiResponseFormat.text) AiResponseFormat responseFormat,
  }) = _AiChatRequest;

  factory AiChatRequest.fromJson(Map<String, dynamic> json) =>
      _$AiChatRequestFromJson(json);
}

@freezed
class AiStreamChunk with _$AiStreamChunk {
  const factory AiStreamChunk({
    @Default('') String deltaText,
    String? finishReason,
    int? promptTokens,
    int? completionTokens,
  }) = _AiStreamChunk;

  factory AiStreamChunk.fromJson(Map<String, dynamic> json) =>
      _$AiStreamChunkFromJson(json);
}

@freezed
class AiChatResponse with _$AiChatResponse {
  const factory AiChatResponse({
    required String text,
    String? finishReason,
    int? promptTokens,
    int? completionTokens,
  }) = _AiChatResponse;

  factory AiChatResponse.fromJson(Map<String, dynamic> json) =>
      _$AiChatResponseFromJson(json);
}

@freezed
class AiConnectionTestResult with _$AiConnectionTestResult {
  const factory AiConnectionTestResult({
    required bool success,
    required String message,
    String? modelId,
  }) = _AiConnectionTestResult;
}
