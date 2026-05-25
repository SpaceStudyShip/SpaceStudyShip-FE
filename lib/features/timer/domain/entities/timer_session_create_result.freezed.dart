// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_create_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerSessionCreateResult {
  TimerSessionEntity get session => throw _privateConstructorUsedError;
  int get fuelCharged => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionCreateResultCopyWith<TimerSessionCreateResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionCreateResultCopyWith<$Res> {
  factory $TimerSessionCreateResultCopyWith(
    TimerSessionCreateResult value,
    $Res Function(TimerSessionCreateResult) then,
  ) = _$TimerSessionCreateResultCopyWithImpl<$Res, TimerSessionCreateResult>;
  @useResult
  $Res call({TimerSessionEntity session, int fuelCharged});

  $TimerSessionEntityCopyWith<$Res> get session;
}

/// @nodoc
class _$TimerSessionCreateResultCopyWithImpl<
  $Res,
  $Val extends TimerSessionCreateResult
>
    implements $TimerSessionCreateResultCopyWith<$Res> {
  _$TimerSessionCreateResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? fuelCharged = null}) {
    return _then(
      _value.copyWith(
            session: null == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as TimerSessionEntity,
            fuelCharged: null == fuelCharged
                ? _value.fuelCharged
                : fuelCharged // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimerSessionEntityCopyWith<$Res> get session {
    return $TimerSessionEntityCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimerSessionCreateResultImplCopyWith<$Res>
    implements $TimerSessionCreateResultCopyWith<$Res> {
  factory _$$TimerSessionCreateResultImplCopyWith(
    _$TimerSessionCreateResultImpl value,
    $Res Function(_$TimerSessionCreateResultImpl) then,
  ) = __$$TimerSessionCreateResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TimerSessionEntity session, int fuelCharged});

  @override
  $TimerSessionEntityCopyWith<$Res> get session;
}

/// @nodoc
class __$$TimerSessionCreateResultImplCopyWithImpl<$Res>
    extends
        _$TimerSessionCreateResultCopyWithImpl<
          $Res,
          _$TimerSessionCreateResultImpl
        >
    implements _$$TimerSessionCreateResultImplCopyWith<$Res> {
  __$$TimerSessionCreateResultImplCopyWithImpl(
    _$TimerSessionCreateResultImpl _value,
    $Res Function(_$TimerSessionCreateResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? fuelCharged = null}) {
    return _then(
      _$TimerSessionCreateResultImpl(
        session: null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as TimerSessionEntity,
        fuelCharged: null == fuelCharged
            ? _value.fuelCharged
            : fuelCharged // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TimerSessionCreateResultImpl implements _TimerSessionCreateResult {
  const _$TimerSessionCreateResultImpl({
    required this.session,
    required this.fuelCharged,
  });

  @override
  final TimerSessionEntity session;
  @override
  final int fuelCharged;

  @override
  String toString() {
    return 'TimerSessionCreateResult(session: $session, fuelCharged: $fuelCharged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionCreateResultImpl &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.fuelCharged, fuelCharged) ||
                other.fuelCharged == fuelCharged));
  }

  @override
  int get hashCode => Object.hash(runtimeType, session, fuelCharged);

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionCreateResultImplCopyWith<_$TimerSessionCreateResultImpl>
  get copyWith =>
      __$$TimerSessionCreateResultImplCopyWithImpl<
        _$TimerSessionCreateResultImpl
      >(this, _$identity);
}

abstract class _TimerSessionCreateResult implements TimerSessionCreateResult {
  const factory _TimerSessionCreateResult({
    required final TimerSessionEntity session,
    required final int fuelCharged,
  }) = _$TimerSessionCreateResultImpl;

  @override
  TimerSessionEntity get session;
  @override
  int get fuelCharged;

  /// Create a copy of TimerSessionCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionCreateResultImplCopyWith<_$TimerSessionCreateResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
