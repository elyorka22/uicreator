// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiProviderConfigImpl _$$AiProviderConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$AiProviderConfigImpl(
      id: json['id'] as String,
      type: $enumDecode(_$AiProviderTypeEnumMap, json['type']),
      displayName: json['displayName'] as String,
      baseUrl: json['baseUrl'] as String,
      modelId: json['modelId'] as String,
      credentialKeyId: json['credentialKeyId'] as String,
      hasCredential: json['hasCredential'] as bool? ?? false,
      lastFourOfKey: json['lastFourOfKey'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AiProviderConfigImplToJson(
        _$AiProviderConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AiProviderTypeEnumMap[instance.type]!,
      'displayName': instance.displayName,
      'baseUrl': instance.baseUrl,
      'modelId': instance.modelId,
      'credentialKeyId': instance.credentialKeyId,
      'hasCredential': instance.hasCredential,
      'lastFourOfKey': instance.lastFourOfKey,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AiProviderTypeEnumMap = {
  AiProviderType.openaiCompatible: 'openaiCompatible',
  AiProviderType.anthropic: 'anthropic',
};
