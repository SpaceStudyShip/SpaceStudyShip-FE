// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_create_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimerSessionCreateRequestModel _$TimerSessionCreateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  return _TimerSessionCreateRequestModel.fromJson(json);
}

/// @nodoc
mixin _$TimerSessionCreateRequestModel {
  @JsonKey(includeIfNull: false)
  String? get todoId => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get todoTitle => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get endedAt => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this TimerSessionCreateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionCreateRequestModelCopyWith<TimerSessionCreateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionCreateRequestModelCopyWith<$Res> {
  factory $TimerSessionCreateRequestModelCopyWith(
    TimerSessionCreateRequestModel value,
    $Res Function(TimerSessionCreateRequestModel) then,
  ) =
      _$TimerSessionCreateRequestModelCopyWithImpl<
        $Res,
        TimerSessionCreateRequestModel
      >;
  @useResult
  $Res call({
    @JsonKey(includeIfNull: false) String? todoId,
    @JsonKey(includeIfNull: false) String? todoTitle,
    DateTime startedAt,
    DateTime endedAt,
    int durationMinutes,
  });
}

/// @nodoc
class _$TimerSessionCreateRequestModelCopyWithImpl<
  $Res,
  $Val extends TimerSessionCreateRequestModel
>
    implements $TimerSessionCreateRequestModelCopyWith<$Res> {
  _$TimerSessionCreateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todoId = freezed,
    Object? todoTitle = freezed,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(
      _value.copyWith(
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
abstract class _$$TimerSessionCreateRequestModelImplCopyWith<$Res>
    implements $TimerSessionCreateRequestModelCopyWith<$Res> {
  factory _$$TimerSessionCreateRequestModelImplCopyWith(
    _$TimerSessionCreateRequestModelImpl value,
    $Res Function(_$TimerSessionCreateRequestModelImpl) then,
  ) = __$$TimerSessionCreateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(includeIfNull: false) String? todoId,
    @JsonKey(includeIfNull: false) String? todoTitle,
    DateTime startedAt,
    DateTime endedAt,
    int durationMinutes,
  });
}

/// @nodoc
class __$$TimerSessionCreateRequestModelImplCopyWithImpl<$Res>
    extends
        _$TimerSessionCreateRequestModelCopyWithImpl<
          $Res,
          _$TimerSessionCreateRequestModelImpl
        >
    implements _$$TimerSessionCreateRequestModelImplCopyWith<$Res> {
  __$$TimerSessionCreateRequestModelImplCopyWithImpl(
    _$TimerSessionCreateRequestModelImpl _value,
    $Res Function(_$TimerSessionCreateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todoId = freezed,
    Object? todoTitle = freezed,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(
      _$TimerSessionCreateRequestModelImpl(
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
class _$TimerSessionCreateRequestModelImpl
    implements _TimerSessionCreateRequestModel {
  const _$TimerSessionCreateRequestModelImpl({
    @JsonKey(includeIfNull: false) this.todoId,
    @JsonKey(includeIfNull: false) this.todoTitle,
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
  });

  factory _$TimerSessionCreateRequestModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TimerSessionCreateRequestModelImplFromJson(json);

  @override
  @JsonKey(includeIfNull: false)
  final String? todoId;
  @override
  @JsonKey(includeIfNull: false)
  final String? todoTitle;
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final int durationMinutes;

  @override
  String toString() {
    return 'TimerSessionCreateRequestModel(todoId: $todoId, todoTitle: $todoTitle, startedAt: $startedAt, endedAt: $endedAt, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionCreateRequestModelImpl &&
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
    todoId,
    todoTitle,
    startedAt,
    endedAt,
    durationMinutes,
  );

  /// Create a copy of TimerSessionCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionCreateRequestModelImplCopyWith<
    _$TimerSessionCreateRequestModelImpl
  >
  get copyWith =>
      __$$TimerSessionCreateRequestModelImplCopyWithImpl<
        _$TimerSessionCreateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerSessionCreateRequestModelImplToJson(this);
  }
}

abstract class _TimerSessionCreateRequestModel
    implements TimerSessionCreateRequestModel {
  const factory _TimerSessionCreateRequestModel({
    @JsonKey(includeIfNull: false) final String? todoId,
    @JsonKey(includeIfNull: false) final String? todoTitle,
    required final DateTime startedAt,
    required final DateTime endedAt,
    required final int durationMinutes,
  }) = _$TimerSessionCreateRequestModelImpl;

  factory _TimerSessionCreateRequestModel.fromJson(Map<String, dynamic> json) =
      _$TimerSessionCreateRequestModelImpl.fromJson;

  @override
  @JsonKey(includeIfNull: false)
  String? get todoId;
  @override
  @JsonKey(includeIfNull: false)
  String? get todoTitle;
  @override
  DateTime get startedAt;
  @override
  DateTime get endedAt;
  @override
  int get durationMinutes;

  /// Create a copy of TimerSessionCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionCreateRequestModelImplCopyWith<
    _$TimerSessionCreateRequestModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
