// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiProviderConfig _$AiProviderConfigFromJson(Map<String, dynamic> json) {
  return _AiProviderConfig.fromJson(json);
}

/// @nodoc
mixin _$AiProviderConfig {
  String get id => throw _privateConstructorUsedError;
  AiProviderType get type => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get baseUrl => throw _privateConstructorUsedError;
  String get modelId => throw _privateConstructorUsedError;

  /// Reference id used to look up the secret in secure storage. Never the key itself.
  String get credentialKeyId => throw _privateConstructorUsedError;
  bool get hasCredential => throw _privateConstructorUsedError;
  String? get lastFourOfKey => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AiProviderConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiProviderConfigCopyWith<AiProviderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiProviderConfigCopyWith<$Res> {
  factory $AiProviderConfigCopyWith(
          AiProviderConfig value, $Res Function(AiProviderConfig) then) =
      _$AiProviderConfigCopyWithImpl<$Res, AiProviderConfig>;
  @useResult
  $Res call(
      {String id,
      AiProviderType type,
      String displayName,
      String baseUrl,
      String modelId,
      String credentialKeyId,
      bool hasCredential,
      String? lastFourOfKey,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AiProviderConfigCopyWithImpl<$Res, $Val extends AiProviderConfig>
    implements $AiProviderConfigCopyWith<$Res> {
  _$AiProviderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? displayName = null,
    Object? baseUrl = null,
    Object? modelId = null,
    Object? credentialKeyId = null,
    Object? hasCredential = null,
    Object? lastFourOfKey = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AiProviderType,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      credentialKeyId: null == credentialKeyId
          ? _value.credentialKeyId
          : credentialKeyId // ignore: cast_nullable_to_non_nullable
              as String,
      hasCredential: null == hasCredential
          ? _value.hasCredential
          : hasCredential // ignore: cast_nullable_to_non_nullable
              as bool,
      lastFourOfKey: freezed == lastFourOfKey
          ? _value.lastFourOfKey
          : lastFourOfKey // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiProviderConfigImplCopyWith<$Res>
    implements $AiProviderConfigCopyWith<$Res> {
  factory _$$AiProviderConfigImplCopyWith(_$AiProviderConfigImpl value,
          $Res Function(_$AiProviderConfigImpl) then) =
      __$$AiProviderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      AiProviderType type,
      String displayName,
      String baseUrl,
      String modelId,
      String credentialKeyId,
      bool hasCredential,
      String? lastFourOfKey,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AiProviderConfigImplCopyWithImpl<$Res>
    extends _$AiProviderConfigCopyWithImpl<$Res, _$AiProviderConfigImpl>
    implements _$$AiProviderConfigImplCopyWith<$Res> {
  __$$AiProviderConfigImplCopyWithImpl(_$AiProviderConfigImpl _value,
      $Res Function(_$AiProviderConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? displayName = null,
    Object? baseUrl = null,
    Object? modelId = null,
    Object? credentialKeyId = null,
    Object? hasCredential = null,
    Object? lastFourOfKey = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AiProviderConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AiProviderType,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String,
      credentialKeyId: null == credentialKeyId
          ? _value.credentialKeyId
          : credentialKeyId // ignore: cast_nullable_to_non_nullable
              as String,
      hasCredential: null == hasCredential
          ? _value.hasCredential
          : hasCredential // ignore: cast_nullable_to_non_nullable
              as bool,
      lastFourOfKey: freezed == lastFourOfKey
          ? _value.lastFourOfKey
          : lastFourOfKey // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiProviderConfigImpl implements _AiProviderConfig {
  const _$AiProviderConfigImpl(
      {required this.id,
      required this.type,
      required this.displayName,
      required this.baseUrl,
      required this.modelId,
      required this.credentialKeyId,
      this.hasCredential = false,
      this.lastFourOfKey,
      this.createdAt,
      this.updatedAt});

  factory _$AiProviderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiProviderConfigImplFromJson(json);

  @override
  final String id;
  @override
  final AiProviderType type;
  @override
  final String displayName;
  @override
  final String baseUrl;
  @override
  final String modelId;

  /// Reference id used to look up the secret in secure storage. Never the key itself.
  @override
  final String credentialKeyId;
  @override
  @JsonKey()
  final bool hasCredential;
  @override
  final String? lastFourOfKey;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AiProviderConfig(id: $id, type: $type, displayName: $displayName, baseUrl: $baseUrl, modelId: $modelId, credentialKeyId: $credentialKeyId, hasCredential: $hasCredential, lastFourOfKey: $lastFourOfKey, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiProviderConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.credentialKeyId, credentialKeyId) ||
                other.credentialKeyId == credentialKeyId) &&
            (identical(other.hasCredential, hasCredential) ||
                other.hasCredential == hasCredential) &&
            (identical(other.lastFourOfKey, lastFourOfKey) ||
                other.lastFourOfKey == lastFourOfKey) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      displayName,
      baseUrl,
      modelId,
      credentialKeyId,
      hasCredential,
      lastFourOfKey,
      createdAt,
      updatedAt);

  /// Create a copy of AiProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiProviderConfigImplCopyWith<_$AiProviderConfigImpl> get copyWith =>
      __$$AiProviderConfigImplCopyWithImpl<_$AiProviderConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiProviderConfigImplToJson(
      this,
    );
  }
}

abstract class _AiProviderConfig implements AiProviderConfig {
  const factory _AiProviderConfig(
      {required final String id,
      required final AiProviderType type,
      required final String displayName,
      required final String baseUrl,
      required final String modelId,
      required final String credentialKeyId,
      final bool hasCredential,
      final String? lastFourOfKey,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$AiProviderConfigImpl;

  factory _AiProviderConfig.fromJson(Map<String, dynamic> json) =
      _$AiProviderConfigImpl.fromJson;

  @override
  String get id;
  @override
  AiProviderType get type;
  @override
  String get displayName;
  @override
  String get baseUrl;
  @override
  String get modelId;

  /// Reference id used to look up the secret in secure storage. Never the key itself.
  @override
  String get credentialKeyId;
  @override
  bool get hasCredential;
  @override
  String? get lastFourOfKey;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AiProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiProviderConfigImplCopyWith<_$AiProviderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
