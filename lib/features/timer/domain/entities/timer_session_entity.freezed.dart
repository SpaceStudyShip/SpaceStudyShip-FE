// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerSessionEntity {
  String get id => throw _privateConstructorUsedError;
  String? get todoId => throw _privateConstructorUsedError;
  String? get todoTitle => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get endedAt => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionEntityCopyWith<TimerSessionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionEntityCopyWith<$Res> {
  factory $TimerSessionEntityCopyWith(
    TimerSessionEntity value,
    $Res Function(TimerSessionEntity) then,
  ) = _$TimerSessionEntityCopyWithImpl<$Res, TimerSessionEntity>;
  @useResult
  $Res call({
    String id,
    String? todoId,
    String? todoTitle,
    DateTime startedAt,
    DateTime endedAt,
    int durationMinutes,
  });
}

/// @nodoc
class _$TimerSessionEntityCopyWithImpl<$Res, $Val extends TimerSessionEntity>
    implements $TimerSessionEntityCopyWith<$Res> {
  _$TimerSessionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = freezed,
    Object? todoTitle = freezed,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            todoId: freezed == todoId
                ? _value.todoId
                : todoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            todoTitle: freezed == todoTitle
                ? _value.todoTitle
                : todoTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: null == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerSessionEntityImplCopyWith<$Res>
    implements $TimerSessionEntityCopyWith<$Res> {
  factory _$$TimerSessionEntityImplCopyWith(
    _$TimerSessionEntityImpl value,
    $Res Function(_$TimerSessionEntityImpl) then,
  ) = __$$TimerSessionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? todoId,
    String? todoTitle,
    DateTime startedAt,
    DateTime endedAt,
    int durationMinutes,
  });
}

/// @nodoc
class __$$TimerSessionEntityImplCopyWithImpl<$Res>
    extends _$TimerSessionEntityCopyWithImpl<$Res, _$TimerSessionEntityImpl>
    implements _$$TimerSessionEntityImplCopyWith<$Res> {
  __$$TimerSessionEntityImplCopyWithImpl(
    _$TimerSessionEntityImpl _value,
    $Res Function(_$TimerSessionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoId = freezed,
    Object? todoTitle = freezed,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(
      _$TimerSessionEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        todoId: freezed == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        todoTitle: freezed == todoTitle
            ? _value.todoTitle
            : todoTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: null == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TimerSessionEntityImpl implements _TimerSessionEntity {
  const _$TimerSessionEntityImpl({
    required this.id,
    this.todoId,
    this.todoTitle,
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
  });

  @override
  final String id;
  @override
  final String? todoId;
  @override
  final String? todoTitle;
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final int durationMinutes;

  @override
  String toString() {
    return 'TimerSessionEntity(id: $id, todoId: $todoId, todoTitle: $todoTitle, startedAt: $startedAt, endedAt: $endedAt, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.todoTitle, todoTitle) ||
                other.todoTitle == todoTitle) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    todoId,
    todoTitle,
    startedAt,
    endedAt,
    durationMinutes,
  );

  /// Create a copy of TimerSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionEntityImplCopyWith<_$TimerSessionEntityImpl> get copyWith =>
      __$$TimerSessionEntityImplCopyWithImpl<_$TimerSessionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _TimerSessionEntity implements TimerSessionEntity {
  const factory _TimerSessionEntity({
    required final String id,
    final String? todoId,
    final String? todoTitle,
    required final DateTime startedAt,
    required final DateTime endedAt,
    required final int durationMinutes,
  }) = _$TimerSessionEntityImpl;

  @override
  String get id;
  @override
  String? get todoId;
  @override
  String? get todoTitle;
  @override
  DateTime get startedAt;
  @override
  DateTime get endedAt;
  @override
  int get durationMinutes;

  /// Create a copy of TimerSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionEntityImplCopyWith<_$TimerSessionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
