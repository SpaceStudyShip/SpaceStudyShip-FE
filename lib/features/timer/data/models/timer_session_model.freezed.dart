// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimerSessionModel _$TimerSessionModelFromJson(Map<String, dynamic> json) {
  return _TimerSessionModel.fromJson(json);
}

/// @nodoc
mixin _$TimerSessionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'todo_id')
  String? get todoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'todo_title')
  String? get todoTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ended_at')
  DateTime get endedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this TimerSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionModelCopyWith<TimerSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionModelCopyWith<$Res> {
  factory $TimerSessionModelCopyWith(
    TimerSessionModel value,
    $Res Function(TimerSessionModel) then,
  ) = _$TimerSessionModelCopyWithImpl<$Res, TimerSessionModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'todo_id') String? todoId,
    @JsonKey(name: 'todo_title') String? todoTitle,
    @JsonKey(name: 'started_at') DateTime startedAt,
    @JsonKey(name: 'ended_at') DateTime endedAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
  });
}

/// @nodoc
class _$TimerSessionModelCopyWithImpl<$Res, $Val extends TimerSessionModel>
    implements $TimerSessionModelCopyWith<$Res> {
  _$TimerSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionModel
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
abstract class _$$TimerSessionModelImplCopyWith<$Res>
    implements $TimerSessionModelCopyWith<$Res> {
  factory _$$TimerSessionModelImplCopyWith(
    _$TimerSessionModelImpl value,
    $Res Function(_$TimerSessionModelImpl) then,
  ) = __$$TimerSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'todo_id') String? todoId,
    @JsonKey(name: 'todo_title') String? todoTitle,
    @JsonKey(name: 'started_at') DateTime startedAt,
    @JsonKey(name: 'ended_at') DateTime endedAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
  });
}

/// @nodoc
class __$$TimerSessionModelImplCopyWithImpl<$Res>
    extends _$TimerSessionModelCopyWithImpl<$Res, _$TimerSessionModelImpl>
    implements _$$TimerSessionModelImplCopyWith<$Res> {
  __$$TimerSessionModelImplCopyWithImpl(
    _$TimerSessionModelImpl _value,
    $Res Function(_$TimerSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionModel
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
      _$TimerSessionModelImpl(
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
@JsonSerializable()
class _$TimerSessionModelImpl implements _TimerSessionModel {
  const _$TimerSessionModelImpl({
    required this.id,
    @JsonKey(name: 'todo_id') this.todoId,
    @JsonKey(name: 'todo_title') this.todoTitle,
    @JsonKey(name: 'started_at') required this.startedAt,
    @JsonKey(name: 'ended_at') required this.endedAt,
    @JsonKey(name: 'duration_minutes') required this.durationMinutes,
  });

  factory _$TimerSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimerSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'todo_id')
  final String? todoId;
  @override
  @JsonKey(name: 'todo_title')
  final String? todoTitle;
  @override
  @JsonKey(name: 'started_at')
  final DateTime startedAt;
  @override
  @JsonKey(name: 'ended_at')
  final DateTime endedAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  @override
  String toString() {
    return 'TimerSessionModel(id: $id, todoId: $todoId, todoTitle: $todoTitle, startedAt: $startedAt, endedAt: $endedAt, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of TimerSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionModelImplCopyWith<_$TimerSessionModelImpl> get copyWith =>
      __$$TimerSessionModelImplCopyWithImpl<_$TimerSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerSessionModelImplToJson(this);
  }
}

abstract class _TimerSessionModel implements TimerSessionModel {
  const factory _TimerSessionModel({
    required final String id,
    @JsonKey(name: 'todo_id') final String? todoId,
    @JsonKey(name: 'todo_title') final String? todoTitle,
    @JsonKey(name: 'started_at') required final DateTime startedAt,
    @JsonKey(name: 'ended_at') required final DateTime endedAt,
    @JsonKey(name: 'duration_minutes') required final int durationMinutes,
  }) = _$TimerSessionModelImpl;

  factory _TimerSessionModel.fromJson(Map<String, dynamic> json) =
      _$TimerSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'todo_id')
  String? get todoId;
  @override
  @JsonKey(name: 'todo_title')
  String? get todoTitle;
  @override
  @JsonKey(name: 'started_at')
  DateTime get startedAt;
  @override
  @JsonKey(name: 'ended_at')
  DateTime get endedAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;

  /// Create a copy of TimerSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionModelImplCopyWith<_$TimerSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
