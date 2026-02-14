// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  Duration get elapsed => throw _privateConstructorUsedError;
  String? get linkedTodoId => throw _privateConstructorUsedError;
  String? get linkedTodoTitle => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({
    TimerStatus status,
    Duration elapsed,
    String? linkedTodoId,
    String? linkedTodoTitle,
  });
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? linkedTodoId = freezed,
    Object? linkedTodoTitle = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TimerStatus,
            elapsed: null == elapsed
                ? _value.elapsed
                : elapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            linkedTodoId: freezed == linkedTodoId
                ? _value.linkedTodoId
                : linkedTodoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            linkedTodoTitle: freezed == linkedTodoTitle
                ? _value.linkedTodoTitle
                : linkedTodoTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TimerStatus status,
    Duration elapsed,
    String? linkedTodoId,
    String? linkedTodoTitle,
  });
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? linkedTodoId = freezed,
    Object? linkedTodoTitle = freezed,
  }) {
    return _then(
      _$TimerStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TimerStatus,
        elapsed: null == elapsed
            ? _value.elapsed
            : elapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        linkedTodoId: freezed == linkedTodoId
            ? _value.linkedTodoId
            : linkedTodoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        linkedTodoTitle: freezed == linkedTodoTitle
            ? _value.linkedTodoTitle
            : linkedTodoTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl({
    this.status = TimerStatus.idle,
    this.elapsed = Duration.zero,
    this.linkedTodoId,
    this.linkedTodoTitle,
  });

  @override
  @JsonKey()
  final TimerStatus status;
  @override
  @JsonKey()
  final Duration elapsed;
  @override
  final String? linkedTodoId;
  @override
  final String? linkedTodoTitle;

  @override
  String toString() {
    return 'TimerState(status: $status, elapsed: $elapsed, linkedTodoId: $linkedTodoId, linkedTodoTitle: $linkedTodoTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            (identical(other.linkedTodoId, linkedTodoId) ||
                other.linkedTodoId == linkedTodoId) &&
            (identical(other.linkedTodoTitle, linkedTodoTitle) ||
                other.linkedTodoTitle == linkedTodoTitle));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, elapsed, linkedTodoId, linkedTodoTitle);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState({
    final TimerStatus status,
    final Duration elapsed,
    final String? linkedTodoId,
    final String? linkedTodoTitle,
  }) = _$TimerStateImpl;

  @override
  TimerStatus get status;
  @override
  Duration get elapsed;
  @override
  String? get linkedTodoId;
  @override
  String? get linkedTodoTitle;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
