// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_nickname_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CheckNicknameResponseModel _$CheckNicknameResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _CheckNicknameResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CheckNicknameResponseModel {
  bool get available => throw _privateConstructorUsedError;

  /// Serializes this CheckNicknameResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckNicknameResponseModelCopyWith<CheckNicknameResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckNicknameResponseModelCopyWith<$Res> {
  factory $CheckNicknameResponseModelCopyWith(
    CheckNicknameResponseModel value,
    $Res Function(CheckNicknameResponseModel) then,
  ) =
      _$CheckNicknameResponseModelCopyWithImpl<
        $Res,
        CheckNicknameResponseModel
      >;
  @useResult
  $Res call({bool available});
}

/// @nodoc
class _$CheckNicknameResponseModelCopyWithImpl<
  $Res,
  $Val extends CheckNicknameResponseModel
>
    implements $CheckNicknameResponseModelCopyWith<$Res> {
  _$CheckNicknameResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? available = null}) {
    return _then(
      _value.copyWith(
            available: null == available
                ? _value.available
                : available // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CheckNicknameResponseModelImplCopyWith<$Res>
    implements $CheckNicknameResponseModelCopyWith<$Res> {
  factory _$$CheckNicknameResponseModelImplCopyWith(
    _$CheckNicknameResponseModelImpl value,
    $Res Function(_$CheckNicknameResponseModelImpl) then,
  ) = __$$CheckNicknameResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool available});
}

/// @nodoc
class __$$CheckNicknameResponseModelImplCopyWithImpl<$Res>
    extends
        _$CheckNicknameResponseModelCopyWithImpl<
          $Res,
          _$CheckNicknameResponseModelImpl
        >
    implements _$$CheckNicknameResponseModelImplCopyWith<$Res> {
  __$$CheckNicknameResponseModelImplCopyWithImpl(
    _$CheckNicknameResponseModelImpl _value,
    $Res Function(_$CheckNicknameResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? available = null}) {
    return _then(
      _$CheckNicknameResponseModelImpl(
        available: null == available
            ? _value.available
            : available // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckNicknameResponseModelImpl implements _CheckNicknameResponseModel {
  const _$CheckNicknameResponseModelImpl({required this.available});

  factory _$CheckNicknameResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CheckNicknameResponseModelImplFromJson(json);

  @override
  final bool available;

  @override
  String toString() {
    return 'CheckNicknameResponseModel(available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckNicknameResponseModelImpl &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, available);

  /// Create a copy of CheckNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckNicknameResponseModelImplCopyWith<_$CheckNicknameResponseModelImpl>
  get copyWith =>
      __$$CheckNicknameResponseModelImplCopyWithImpl<
        _$CheckNicknameResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckNicknameResponseModelImplToJson(this);
  }
}

abstract class _CheckNicknameResponseModel
    implements CheckNicknameResponseModel {
  const factory _CheckNicknameResponseModel({required final bool available}) =
      _$CheckNicknameResponseModelImpl;

  factory _CheckNicknameResponseModel.fromJson(Map<String, dynamic> json) =
      _$CheckNicknameResponseModelImpl.fromJson;

  @override
  bool get available;

  /// Create a copy of CheckNicknameResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckNicknameResponseModelImplCopyWith<_$CheckNicknameResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
