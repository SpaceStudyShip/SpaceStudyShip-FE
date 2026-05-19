// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_nickname_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpdateNicknameRequestModel _$UpdateNicknameRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateNicknameRequestModel.fromJson(json);
}

/// @nodoc
mixin _$UpdateNicknameRequestModel {
  String get nickname => throw _privateConstructorUsedError;

  /// Serializes this UpdateNicknameRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateNicknameRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateNicknameRequestModelCopyWith<UpdateNicknameRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateNicknameRequestModelCopyWith<$Res> {
  factory $UpdateNicknameRequestModelCopyWith(
    UpdateNicknameRequestModel value,
    $Res Function(UpdateNicknameRequestModel) then,
  ) =
      _$UpdateNicknameRequestModelCopyWithImpl<
        $Res,
        UpdateNicknameRequestModel
      >;
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class _$UpdateNicknameRequestModelCopyWithImpl<
  $Res,
  $Val extends UpdateNicknameRequestModel
>
    implements $UpdateNicknameRequestModelCopyWith<$Res> {
  _$UpdateNicknameRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateNicknameRequestModel
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
abstract class _$$UpdateNicknameRequestModelImplCopyWith<$Res>
    implements $UpdateNicknameRequestModelCopyWith<$Res> {
  factory _$$UpdateNicknameRequestModelImplCopyWith(
    _$UpdateNicknameRequestModelImpl value,
    $Res Function(_$UpdateNicknameRequestModelImpl) then,
  ) = __$$UpdateNicknameRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nickname});
}

/// @nodoc
class __$$UpdateNicknameRequestModelImplCopyWithImpl<$Res>
    extends
        _$UpdateNicknameRequestModelCopyWithImpl<
          $Res,
          _$UpdateNicknameRequestModelImpl
        >
    implements _$$UpdateNicknameRequestModelImplCopyWith<$Res> {
  __$$UpdateNicknameRequestModelImplCopyWithImpl(
    _$UpdateNicknameRequestModelImpl _value,
    $Res Function(_$UpdateNicknameRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateNicknameRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nickname = null}) {
    return _then(
      _$UpdateNicknameRequestModelImpl(
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
class _$UpdateNicknameRequestModelImpl implements _UpdateNicknameRequestModel {
  const _$UpdateNicknameRequestModelImpl({required this.nickname});

  factory _$UpdateNicknameRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UpdateNicknameRequestModelImplFromJson(json);

  @override
  final String nickname;

  @override
  String toString() {
    return 'UpdateNicknameRequestModel(nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateNicknameRequestModelImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nickname);

  /// Create a copy of UpdateNicknameRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateNicknameRequestModelImplCopyWith<_$UpdateNicknameRequestModelImpl>
  get copyWith =>
      __$$UpdateNicknameRequestModelImplCopyWithImpl<
        _$UpdateNicknameRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateNicknameRequestModelImplToJson(this);
  }
}

abstract class _UpdateNicknameRequestModel
    implements UpdateNicknameRequestModel {
  const factory _UpdateNicknameRequestModel({required final String nickname}) =
      _$UpdateNicknameRequestModelImpl;

  factory _UpdateNicknameRequestModel.fromJson(Map<String, dynamic> json) =
      _$UpdateNicknameRequestModelImpl.fromJson;

  @override
  String get nickname;

  /// Create a copy of UpdateNicknameRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateNicknameRequestModelImplCopyWith<_$UpdateNicknameRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
