// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiModelInfo _$AiModelInfoFromJson(Map<String, dynamic> json) {
  return _AiModelInfo.fromJson(json);
}

/// @nodoc
mixin _$AiModelInfo {
  String get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this AiModelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiModelInfoCopyWith<AiModelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiModelInfoCopyWith<$Res> {
  factory $AiModelInfoCopyWith(
          AiModelInfo value, $Res Function(AiModelInfo) then) =
      _$AiModelInfoCopyWithImpl<$Res, AiModelInfo>;
  @useResult
  $Res call({String id, String displayName, String? description});
}

/// @nodoc
class _$AiModelInfoCopyWithImpl<$Res, $Val extends AiModelInfo>
    implements $AiModelInfoCopyWith<$Res> {
  _$AiModelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiModelInfoImplCopyWith<$Res>
    implements $AiModelInfoCopyWith<$Res> {
  factory _$$AiModelInfoImplCopyWith(
          _$AiModelInfoImpl value, $Res Function(_$AiModelInfoImpl) then) =
      __$$AiModelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String displayName, String? description});
}

/// @nodoc
class __$$AiModelInfoImplCopyWithImpl<$Res>
    extends _$AiModelInfoCopyWithImpl<$Res, _$AiModelInfoImpl>
    implements _$$AiModelInfoImplCopyWith<$Res> {
  __$$AiModelInfoImplCopyWithImpl(
      _$AiModelInfoImpl _value, $Res Function(_$AiModelInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? description = freezed,
  }) {
    return _then(_$AiModelInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiModelInfoImpl implements _AiModelInfo {
  const _$AiModelInfoImpl(
      {required this.id, required this.displayName, this.description});

  factory _$AiModelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiModelInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? description;

  @override
  String toString() {
    return 'AiModelInfo(id: $id, displayName: $displayName, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiModelInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, displayName, description);

  /// Create a copy of AiModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiModelInfoImplCopyWith<_$AiModelInfoImpl> get copyWith =>
      __$$AiModelInfoImplCopyWithImpl<_$AiModelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiModelInfoImplToJson(
      this,
    );
  }
}

abstract class _AiModelInfo implements AiModelInfo {
  const factory _AiModelInfo(
      {required final String id,
      required final String displayName,
      final String? description}) = _$AiModelInfoImpl;

  factory _AiModelInfo.fromJson(Map<String, dynamic> json) =
      _$AiModelInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get displayName;
  @override
  String? get description;

  /// Create a copy of AiModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiModelInfoImplCopyWith<_$AiModelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiChatMessage _$AiChatMessageFromJson(Map<String, dynamic> json) {
  return _AiChatMessage.fromJson(json);
}

/// @nodoc
mixin _$AiChatMessage {
  AiMessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this AiChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatMessageCopyWith<AiChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatMessageCopyWith<$Res> {
  factory $AiChatMessageCopyWith(
          AiChatMessage value, $Res Function(AiChatMessage) then) =
      _$AiChatMessageCopyWithImpl<$Res, AiChatMessage>;
  @useResult
  $Res call({AiMessageRole role, String content});
}

/// @nodoc
class _$AiChatMessageCopyWithImpl<$Res, $Val extends AiChatMessage>
    implements $AiChatMessageCopyWith<$Res> {
  _$AiChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AiMessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatMessageImplCopyWith<$Res>
    implements $AiChatMessageCopyWith<$Res> {
  factory _$$AiChatMessageImplCopyWith(
          _$AiChatMessageImpl value, $Res Function(_$AiChatMessageImpl) then) =
      __$$AiChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AiMessageRole role, String content});
}

/// @nodoc
class __$$AiChatMessageImplCopyWithImpl<$Res>
    extends _$AiChatMessageCopyWithImpl<$Res, _$AiChatMessageImpl>
    implements _$$AiChatMessageImplCopyWith<$Res> {
  __$$AiChatMessageImplCopyWithImpl(
      _$AiChatMessageImpl _value, $Res Function(_$AiChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
  }) {
    return _then(_$AiChatMessageImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AiMessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiChatMessageImpl implements _AiChatMessage {
  const _$AiChatMessageImpl({required this.role, required this.content});

  factory _$AiChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatMessageImplFromJson(json);

  @override
  final AiMessageRole role;
  @override
  final String content;

  @override
  String toString() {
    return 'AiChatMessage(role: $role, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role, content);

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      __$$AiChatMessageImplCopyWithImpl<_$AiChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatMessageImplToJson(
      this,
    );
  }
}

abstract class _AiChatMessage implements AiChatMessage {
  const factory _AiChatMessage(
      {required final AiMessageRole role,
      required final String content}) = _$AiChatMessageImpl;

  factory _AiChatMessage.fromJson(Map<String, dynamic> json) =
      _$AiChatMessageImpl.fromJson;

  @override
  AiMessageRole get role;
  @override
  String get content;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiChatRequest _$AiChatRequestFromJson(Map<String, dynamic> json) {
  return _AiChatRequest.fromJson(json);
}

/// @nodoc
mixin _$AiChatRequest {
  String get model => throw _privateConstructorUsedError;
  List<AiChatMessage> get messages => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int? get maxTokens => throw _privateConstructorUsedError;
  AiResponseFormat get responseFormat => throw _privateConstructorUsedError;

  /// Serializes this AiChatRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatRequestCopyWith<AiChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatRequestCopyWith<$Res> {
  factory $AiChatRequestCopyWith(
          AiChatRequest value, $Res Function(AiChatRequest) then) =
      _$AiChatRequestCopyWithImpl<$Res, AiChatRequest>;
  @useResult
  $Res call(
      {String model,
      List<AiChatMessage> messages,
      double temperature,
      int? maxTokens,
      AiResponseFormat responseFormat});
}

/// @nodoc
class _$AiChatRequestCopyWithImpl<$Res, $Val extends AiChatRequest>
    implements $AiChatRequestCopyWith<$Res> {
  _$AiChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? messages = null,
    Object? temperature = null,
    Object? maxTokens = freezed,
    Object? responseFormat = null,
  }) {
    return _then(_value.copyWith(
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessage>,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      responseFormat: null == responseFormat
          ? _value.responseFormat
          : responseFormat // ignore: cast_nullable_to_non_nullable
              as AiResponseFormat,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatRequestImplCopyWith<$Res>
    implements $AiChatRequestCopyWith<$Res> {
  factory _$$AiChatRequestImplCopyWith(
          _$AiChatRequestImpl value, $Res Function(_$AiChatRequestImpl) then) =
      __$$AiChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String model,
      List<AiChatMessage> messages,
      double temperature,
      int? maxTokens,
      AiResponseFormat responseFormat});
}

/// @nodoc
class __$$AiChatRequestImplCopyWithImpl<$Res>
    extends _$AiChatRequestCopyWithImpl<$Res, _$AiChatRequestImpl>
    implements _$$AiChatRequestImplCopyWith<$Res> {
  __$$AiChatRequestImplCopyWithImpl(
      _$AiChatRequestImpl _value, $Res Function(_$AiChatRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? messages = null,
    Object? temperature = null,
    Object? maxTokens = freezed,
    Object? responseFormat = null,
  }) {
    return _then(_$AiChatRequestImpl(
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessage>,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      responseFormat: null == responseFormat
          ? _value.responseFormat
          : responseFormat // ignore: cast_nullable_to_non_nullable
              as AiResponseFormat,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiChatRequestImpl implements _AiChatRequest {
  const _$AiChatRequestImpl(
      {required this.model,
      required final List<AiChatMessage> messages,
      this.temperature = 0.7,
      this.maxTokens,
      this.responseFormat = AiResponseFormat.text})
      : _messages = messages;

  factory _$AiChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatRequestImplFromJson(json);

  @override
  final String model;
  final List<AiChatMessage> _messages;
  @override
  List<AiChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final double temperature;
  @override
  final int? maxTokens;
  @override
  @JsonKey()
  final AiResponseFormat responseFormat;

  @override
  String toString() {
    return 'AiChatRequest(model: $model, messages: $messages, temperature: $temperature, maxTokens: $maxTokens, responseFormat: $responseFormat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatRequestImpl &&
            (identical(other.model, model) || other.model == model) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.responseFormat, responseFormat) ||
                other.responseFormat == responseFormat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      model,
      const DeepCollectionEquality().hash(_messages),
      temperature,
      maxTokens,
      responseFormat);

  /// Create a copy of AiChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatRequestImplCopyWith<_$AiChatRequestImpl> get copyWith =>
      __$$AiChatRequestImplCopyWithImpl<_$AiChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatRequestImplToJson(
      this,
    );
  }
}

abstract class _AiChatRequest implements AiChatRequest {
  const factory _AiChatRequest(
      {required final String model,
      required final List<AiChatMessage> messages,
      final double temperature,
      final int? maxTokens,
      final AiResponseFormat responseFormat}) = _$AiChatRequestImpl;

  factory _AiChatRequest.fromJson(Map<String, dynamic> json) =
      _$AiChatRequestImpl.fromJson;

  @override
  String get model;
  @override
  List<AiChatMessage> get messages;
  @override
  double get temperature;
  @override
  int? get maxTokens;
  @override
  AiResponseFormat get responseFormat;

  /// Create a copy of AiChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatRequestImplCopyWith<_$AiChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiStreamChunk _$AiStreamChunkFromJson(Map<String, dynamic> json) {
  return _AiStreamChunk.fromJson(json);
}

/// @nodoc
mixin _$AiStreamChunk {
  String get deltaText => throw _privateConstructorUsedError;
  String? get finishReason => throw _privateConstructorUsedError;
  int? get promptTokens => throw _privateConstructorUsedError;
  int? get completionTokens => throw _privateConstructorUsedError;

  /// Serializes this AiStreamChunk to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiStreamChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiStreamChunkCopyWith<AiStreamChunk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiStreamChunkCopyWith<$Res> {
  factory $AiStreamChunkCopyWith(
          AiStreamChunk value, $Res Function(AiStreamChunk) then) =
      _$AiStreamChunkCopyWithImpl<$Res, AiStreamChunk>;
  @useResult
  $Res call(
      {String deltaText,
      String? finishReason,
      int? promptTokens,
      int? completionTokens});
}

/// @nodoc
class _$AiStreamChunkCopyWithImpl<$Res, $Val extends AiStreamChunk>
    implements $AiStreamChunkCopyWith<$Res> {
  _$AiStreamChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiStreamChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deltaText = null,
    Object? finishReason = freezed,
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
  }) {
    return _then(_value.copyWith(
      deltaText: null == deltaText
          ? _value.deltaText
          : deltaText // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _value.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as String?,
      promptTokens: freezed == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      completionTokens: freezed == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiStreamChunkImplCopyWith<$Res>
    implements $AiStreamChunkCopyWith<$Res> {
  factory _$$AiStreamChunkImplCopyWith(
          _$AiStreamChunkImpl value, $Res Function(_$AiStreamChunkImpl) then) =
      __$$AiStreamChunkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deltaText,
      String? finishReason,
      int? promptTokens,
      int? completionTokens});
}

/// @nodoc
class __$$AiStreamChunkImplCopyWithImpl<$Res>
    extends _$AiStreamChunkCopyWithImpl<$Res, _$AiStreamChunkImpl>
    implements _$$AiStreamChunkImplCopyWith<$Res> {
  __$$AiStreamChunkImplCopyWithImpl(
      _$AiStreamChunkImpl _value, $Res Function(_$AiStreamChunkImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiStreamChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deltaText = null,
    Object? finishReason = freezed,
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
  }) {
    return _then(_$AiStreamChunkImpl(
      deltaText: null == deltaText
          ? _value.deltaText
          : deltaText // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _value.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as String?,
      promptTokens: freezed == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      completionTokens: freezed == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiStreamChunkImpl implements _AiStreamChunk {
  const _$AiStreamChunkImpl(
      {this.deltaText = '',
      this.finishReason,
      this.promptTokens,
      this.completionTokens});

  factory _$AiStreamChunkImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiStreamChunkImplFromJson(json);

  @override
  @JsonKey()
  final String deltaText;
  @override
  final String? finishReason;
  @override
  final int? promptTokens;
  @override
  final int? completionTokens;

  @override
  String toString() {
    return 'AiStreamChunk(deltaText: $deltaText, finishReason: $finishReason, promptTokens: $promptTokens, completionTokens: $completionTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiStreamChunkImpl &&
            (identical(other.deltaText, deltaText) ||
                other.deltaText == deltaText) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.promptTokens, promptTokens) ||
                other.promptTokens == promptTokens) &&
            (identical(other.completionTokens, completionTokens) ||
                other.completionTokens == completionTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, deltaText, finishReason, promptTokens, completionTokens);

  /// Create a copy of AiStreamChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiStreamChunkImplCopyWith<_$AiStreamChunkImpl> get copyWith =>
      __$$AiStreamChunkImplCopyWithImpl<_$AiStreamChunkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiStreamChunkImplToJson(
      this,
    );
  }
}

abstract class _AiStreamChunk implements AiStreamChunk {
  const factory _AiStreamChunk(
      {final String deltaText,
      final String? finishReason,
      final int? promptTokens,
      final int? completionTokens}) = _$AiStreamChunkImpl;

  factory _AiStreamChunk.fromJson(Map<String, dynamic> json) =
      _$AiStreamChunkImpl.fromJson;

  @override
  String get deltaText;
  @override
  String? get finishReason;
  @override
  int? get promptTokens;
  @override
  int? get completionTokens;

  /// Create a copy of AiStreamChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiStreamChunkImplCopyWith<_$AiStreamChunkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiChatResponse _$AiChatResponseFromJson(Map<String, dynamic> json) {
  return _AiChatResponse.fromJson(json);
}

/// @nodoc
mixin _$AiChatResponse {
  String get text => throw _privateConstructorUsedError;
  String? get finishReason => throw _privateConstructorUsedError;
  int? get promptTokens => throw _privateConstructorUsedError;
  int? get completionTokens => throw _privateConstructorUsedError;

  /// Serializes this AiChatResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatResponseCopyWith<AiChatResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatResponseCopyWith<$Res> {
  factory $AiChatResponseCopyWith(
          AiChatResponse value, $Res Function(AiChatResponse) then) =
      _$AiChatResponseCopyWithImpl<$Res, AiChatResponse>;
  @useResult
  $Res call(
      {String text,
      String? finishReason,
      int? promptTokens,
      int? completionTokens});
}

/// @nodoc
class _$AiChatResponseCopyWithImpl<$Res, $Val extends AiChatResponse>
    implements $AiChatResponseCopyWith<$Res> {
  _$AiChatResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? finishReason = freezed,
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _value.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as String?,
      promptTokens: freezed == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      completionTokens: freezed == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatResponseImplCopyWith<$Res>
    implements $AiChatResponseCopyWith<$Res> {
  factory _$$AiChatResponseImplCopyWith(_$AiChatResponseImpl value,
          $Res Function(_$AiChatResponseImpl) then) =
      __$$AiChatResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String text,
      String? finishReason,
      int? promptTokens,
      int? completionTokens});
}

/// @nodoc
class __$$AiChatResponseImplCopyWithImpl<$Res>
    extends _$AiChatResponseCopyWithImpl<$Res, _$AiChatResponseImpl>
    implements _$$AiChatResponseImplCopyWith<$Res> {
  __$$AiChatResponseImplCopyWithImpl(
      _$AiChatResponseImpl _value, $Res Function(_$AiChatResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? finishReason = freezed,
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
  }) {
    return _then(_$AiChatResponseImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      finishReason: freezed == finishReason
          ? _value.finishReason
          : finishReason // ignore: cast_nullable_to_non_nullable
              as String?,
      promptTokens: freezed == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      completionTokens: freezed == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiChatResponseImpl implements _AiChatResponse {
  const _$AiChatResponseImpl(
      {required this.text,
      this.finishReason,
      this.promptTokens,
      this.completionTokens});

  factory _$AiChatResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatResponseImplFromJson(json);

  @override
  final String text;
  @override
  final String? finishReason;
  @override
  final int? promptTokens;
  @override
  final int? completionTokens;

  @override
  String toString() {
    return 'AiChatResponse(text: $text, finishReason: $finishReason, promptTokens: $promptTokens, completionTokens: $completionTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatResponseImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.promptTokens, promptTokens) ||
                other.promptTokens == promptTokens) &&
            (identical(other.completionTokens, completionTokens) ||
                other.completionTokens == completionTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, text, finishReason, promptTokens, completionTokens);

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatResponseImplCopyWith<_$AiChatResponseImpl> get copyWith =>
      __$$AiChatResponseImplCopyWithImpl<_$AiChatResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatResponseImplToJson(
      this,
    );
  }
}

abstract class _AiChatResponse implements AiChatResponse {
  const factory _AiChatResponse(
      {required final String text,
      final String? finishReason,
      final int? promptTokens,
      final int? completionTokens}) = _$AiChatResponseImpl;

  factory _AiChatResponse.fromJson(Map<String, dynamic> json) =
      _$AiChatResponseImpl.fromJson;

  @override
  String get text;
  @override
  String? get finishReason;
  @override
  int? get promptTokens;
  @override
  int? get completionTokens;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatResponseImplCopyWith<_$AiChatResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AiConnectionTestResult {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get modelId => throw _privateConstructorUsedError;

  /// Create a copy of AiConnectionTestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiConnectionTestResultCopyWith<AiConnectionTestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiConnectionTestResultCopyWith<$Res> {
  factory $AiConnectionTestResultCopyWith(AiConnectionTestResult value,
          $Res Function(AiConnectionTestResult) then) =
      _$AiConnectionTestResultCopyWithImpl<$Res, AiConnectionTestResult>;
  @useResult
  $Res call({bool success, String message, String? modelId});
}

/// @nodoc
class _$AiConnectionTestResultCopyWithImpl<$Res,
        $Val extends AiConnectionTestResult>
    implements $AiConnectionTestResultCopyWith<$Res> {
  _$AiConnectionTestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiConnectionTestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? modelId = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiConnectionTestResultImplCopyWith<$Res>
    implements $AiConnectionTestResultCopyWith<$Res> {
  factory _$$AiConnectionTestResultImplCopyWith(
          _$AiConnectionTestResultImpl value,
          $Res Function(_$AiConnectionTestResultImpl) then) =
      __$$AiConnectionTestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, String? modelId});
}

/// @nodoc
class __$$AiConnectionTestResultImplCopyWithImpl<$Res>
    extends _$AiConnectionTestResultCopyWithImpl<$Res,
        _$AiConnectionTestResultImpl>
    implements _$$AiConnectionTestResultImplCopyWith<$Res> {
  __$$AiConnectionTestResultImplCopyWithImpl(
      _$AiConnectionTestResultImpl _value,
      $Res Function(_$AiConnectionTestResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiConnectionTestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? modelId = freezed,
  }) {
    return _then(_$AiConnectionTestResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AiConnectionTestResultImpl implements _AiConnectionTestResult {
  const _$AiConnectionTestResultImpl(
      {required this.success, required this.message, this.modelId});

  @override
  final bool success;
  @override
  final String message;
  @override
  final String? modelId;

  @override
  String toString() {
    return 'AiConnectionTestResult(success: $success, message: $message, modelId: $modelId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiConnectionTestResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.modelId, modelId) || other.modelId == modelId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, success, message, modelId);

  /// Create a copy of AiConnectionTestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiConnectionTestResultImplCopyWith<_$AiConnectionTestResultImpl>
      get copyWith => __$$AiConnectionTestResultImplCopyWithImpl<
          _$AiConnectionTestResultImpl>(this, _$identity);
}

abstract class _AiConnectionTestResult implements AiConnectionTestResult {
  const factory _AiConnectionTestResult(
      {required final bool success,
      required final String message,
      final String? modelId}) = _$AiConnectionTestResultImpl;

  @override
  bool get success;
  @override
  String get message;
  @override
  String? get modelId;

  /// Create a copy of AiConnectionTestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiConnectionTestResultImplCopyWith<_$AiConnectionTestResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
