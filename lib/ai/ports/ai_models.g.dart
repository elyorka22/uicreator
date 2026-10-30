// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiModelInfoImpl _$$AiModelInfoImplFromJson(Map<String, dynamic> json) =>
    _$AiModelInfoImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$AiModelInfoImplToJson(_$AiModelInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'description': instance.description,
    };

_$AiChatMessageImpl _$$AiChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$AiChatMessageImpl(
      role: $enumDecode(_$AiMessageRoleEnumMap, json['role']),
      content: json['content'] as String,
    );

Map<String, dynamic> _$$AiChatMessageImplToJson(_$AiChatMessageImpl instance) =>
    <String, dynamic>{
      'role': _$AiMessageRoleEnumMap[instance.role]!,
      'content': instance.content,
    };

const _$AiMessageRoleEnumMap = {
  AiMessageRole.system: 'system',
  AiMessageRole.user: 'user',
  AiMessageRole.assistant: 'assistant',
};

_$AiChatRequestImpl _$$AiChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$AiChatRequestImpl(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt(),
      responseFormat: $enumDecodeNullable(
              _$AiResponseFormatEnumMap, json['responseFormat']) ??
          AiResponseFormat.text,
    );

Map<String, dynamic> _$$AiChatRequestImplToJson(_$AiChatRequestImpl instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'responseFormat': _$AiResponseFormatEnumMap[instance.responseFormat]!,
    };

const _$AiResponseFormatEnumMap = {
  AiResponseFormat.text: 'text',
  AiResponseFormat.jsonObject: 'jsonObject',
};

_$AiStreamChunkImpl _$$AiStreamChunkImplFromJson(Map<String, dynamic> json) =>
    _$AiStreamChunkImpl(
      deltaText: json['deltaText'] as String? ?? '',
      finishReason: json['finishReason'] as String?,
      promptTokens: (json['promptTokens'] as num?)?.toInt(),
      completionTokens: (json['completionTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AiStreamChunkImplToJson(_$AiStreamChunkImpl instance) =>
    <String, dynamic>{
      'deltaText': instance.deltaText,
      'finishReason': instance.finishReason,
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
    };

_$AiChatResponseImpl _$$AiChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$AiChatResponseImpl(
      text: json['text'] as String,
      finishReason: json['finishReason'] as String?,
      promptTokens: (json['promptTokens'] as num?)?.toInt(),
      completionTokens: (json['completionTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AiChatResponseImplToJson(
        _$AiChatResponseImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'finishReason': instance.finishReason,
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
    };
