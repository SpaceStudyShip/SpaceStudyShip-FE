// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_nickname_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpdateNicknameResponseModel _$UpdateNicknameResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateNicknameResponseModel.fromJson(json);
}

/// @nodoc
mixin _$UpdateNicknameResponseModel {
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this UpdateNicknameResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateNicknameResponseModelCopyWith<UpdateNicknameResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateNicknameResponseModelCopyWith<$Res> {
  factory $UpdateNicknameResponseModelCopyWith(
    UpdateNicknameResponseModel value,
    $Res Function(UpdateNicknameResponseModel) then,
  ) =
      _$UpdateNicknameResponseModelCopyWithImpl<
        $Res,
        UpdateNicknameResponseModel
      >;
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class _$UpdateNicknameResponseModelCopyWithImpl<
  $Res,
  $Val extends UpdateNicknameResponseModel
>
    implements $UpdateNicknameResponseModelCopyWith<$Res> {
  _$UpdateNicknameResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _value.copyWith(
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateNicknameResponseModelImplCopyWith<$Res>
    implements $UpdateNicknameResponseModelCopyWith<$Res> {
  factory _$$UpdateNicknameResponseModelImplCopyWith(
    _$UpdateNicknameResponseModelImpl value,
    $Res Function(_$UpdateNicknameResponseModelImpl) then,
  ) = __$$UpdateNicknameResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class __$$UpdateNicknameResponseModelImplCopyWithImpl<$Res>
    extends
        _$UpdateNicknameResponseModelCopyWithImpl<
          $Res,
          _$UpdateNicknameResponseModelImpl
        >
    implements _$$UpdateNicknameResponseModelImplCopyWith<$Res> {
  __$$UpdateNicknameResponseModelImplCopyWithImpl(
    _$UpdateNicknameResponseModelImpl _value,
    $Res Function(_$UpdateNicknameResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _$UpdateNicknameResponseModelImpl(
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateNicknameResponseModelImpl
    implements _UpdateNicknameResponseModel {
  const _$UpdateNicknameResponseModelImpl({required this.nickname});

  factory _$UpdateNicknameResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UpdateNicknameResponseModelImplFromJson(json);

  @override
  final String nickname;

  @override
  String toString() {
    return 'UpdateNicknameResponseModel(nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateNicknameResponseModelImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nickname);

  /// Create a copy of UpdateNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateNicknameResponseModelImplCopyWith<_$UpdateNicknameResponseModelImpl>
  get copyWith =>
      __$$UpdateNicknameResponseModelImplCopyWithImpl<
        _$UpdateNicknameResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateNicknameResponseModelImplToJson(this);
  }
}

abstract class _UpdateNicknameResponseModel
    implements UpdateNicknameResponseModel {
  const factory _UpdateNicknameResponseModel({required final String nickname}) =
      _$UpdateNicknameResponseModelImpl;

  factory _UpdateNicknameResponseModel.fromJson(Map<String, dynamic> json) =
      _$UpdateNicknameResponseModelImpl.fromJson;

  @override
  String get nickname;

  /// Create a copy of UpdateNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateNicknameResponseModelImplCopyWith<_$UpdateNicknameResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
