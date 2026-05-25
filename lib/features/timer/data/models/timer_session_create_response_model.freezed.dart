// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_create_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimerSessionCreateResponseModel _$TimerSessionCreateResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _TimerSessionCreateResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TimerSessionCreateResponseModel {
  TimerSessionResponseModel get session => throw _privateConstructorUsedError;
  int get fuelCharged => throw _privateConstructorUsedError;

  /// Serializes this TimerSessionCreateResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionCreateResponseModelCopyWith<TimerSessionCreateResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionCreateResponseModelCopyWith<$Res> {
  factory $TimerSessionCreateResponseModelCopyWith(
    TimerSessionCreateResponseModel value,
    $Res Function(TimerSessionCreateResponseModel) then,
  ) =
      _$TimerSessionCreateResponseModelCopyWithImpl<
        $Res,
        TimerSessionCreateResponseModel
      >;
  @useResult
  $Res call({TimerSessionResponseModel session, int fuelCharged});

  $TimerSessionResponseModelCopyWith<$Res> get session;
}

/// @nodoc
class _$TimerSessionCreateResponseModelCopyWithImpl<
  $Res,
  $Val extends TimerSessionCreateResponseModel
>
    implements $TimerSessionCreateResponseModelCopyWith<$Res> {
  _$TimerSessionCreateResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? fuelCharged = null}) {
    return _then(
      _value.copyWith(
            session: null == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as TimerSessionResponseModel,
            fuelCharged: null == fuelCharged
                ? _value.fuelCharged
                : fuelCharged // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimerSessionResponseModelCopyWith<$Res> get session {
    return $TimerSessionResponseModelCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimerSessionCreateResponseModelImplCopyWith<$Res>
    implements $TimerSessionCreateResponseModelCopyWith<$Res> {
  factory _$$TimerSessionCreateResponseModelImplCopyWith(
    _$TimerSessionCreateResponseModelImpl value,
    $Res Function(_$TimerSessionCreateResponseModelImpl) then,
  ) = __$$TimerSessionCreateResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TimerSessionResponseModel session, int fuelCharged});

  @override
  $TimerSessionResponseModelCopyWith<$Res> get session;
}

/// @nodoc
class __$$TimerSessionCreateResponseModelImplCopyWithImpl<$Res>
    extends
        _$TimerSessionCreateResponseModelCopyWithImpl<
          $Res,
          _$TimerSessionCreateResponseModelImpl
        >
    implements _$$TimerSessionCreateResponseModelImplCopyWith<$Res> {
  __$$TimerSessionCreateResponseModelImplCopyWithImpl(
    _$TimerSessionCreateResponseModelImpl _value,
    $Res Function(_$TimerSessionCreateResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? fuelCharged = null}) {
    return _then(
      _$TimerSessionCreateResponseModelImpl(
        session: null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as TimerSessionResponseModel,
        fuelCharged: null == fuelCharged
            ? _value.fuelCharged
            : fuelCharged // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimerSessionCreateResponseModelImpl
    extends _TimerSessionCreateResponseModel {
  const _$TimerSessionCreateResponseModelImpl({
    required this.session,
    required this.fuelCharged,
  }) : super._();

  factory _$TimerSessionCreateResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TimerSessionCreateResponseModelImplFromJson(json);

  @override
  final TimerSessionResponseModel session;
  @override
  final int fuelCharged;

  @override
  String toString() {
    return 'TimerSessionCreateResponseModel(session: $session, fuelCharged: $fuelCharged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionCreateResponseModelImpl &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.fuelCharged, fuelCharged) ||
                other.fuelCharged == fuelCharged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, session, fuelCharged);

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionCreateResponseModelImplCopyWith<
    _$TimerSessionCreateResponseModelImpl
  >
  get copyWith =>
      __$$TimerSessionCreateResponseModelImplCopyWithImpl<
        _$TimerSessionCreateResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerSessionCreateResponseModelImplToJson(this);
  }
}

abstract class _TimerSessionCreateResponseModel
    extends TimerSessionCreateResponseModel {
  const factory _TimerSessionCreateResponseModel({
    required final TimerSessionResponseModel session,
    required final int fuelCharged,
  }) = _$TimerSessionCreateResponseModelImpl;
  const _TimerSessionCreateResponseModel._() : super._();

  factory _TimerSessionCreateResponseModel.fromJson(Map<String, dynamic> json) =
      _$TimerSessionCreateResponseModelImpl.fromJson;

  @override
  TimerSessionResponseModel get session;
  @override
  int get fuelCharged;

  /// Create a copy of TimerSessionCreateResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionCreateResponseModelImplCopyWith<
    _$TimerSessionCreateResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
