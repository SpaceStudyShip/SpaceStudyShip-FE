// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<DateTime> get scheduledDates => throw _privateConstructorUsedError;
  List<DateTime> get completedDates => throw _privateConstructorUsedError;
  List<String> get categoryIds => throw _privateConstructorUsedError;
  int? get estimatedMinutes => throw _privateConstructorUsedError;
  int? get actualMinutes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoEntityCopyWith<TodoEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoEntityCopyWith<$Res> {
  factory $TodoEntityCopyWith(
    TodoEntity value,
    $Res Function(TodoEntity) then,
  ) = _$TodoEntityCopyWithImpl<$Res, TodoEntity>;
  @useResult
  $Res call({
    String id,
    String title,
    List<DateTime> scheduledDates,
    List<DateTime> completedDates,
    List<String> categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TodoEntityCopyWithImpl<$Res, $Val extends TodoEntity>
    implements $TodoEntityCopyWith<$Res> {
  _$TodoEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? scheduledDates = null,
    Object? completedDates = null,
    Object? categoryIds = null,
    Object? estimatedMinutes = freezed,
    Object? actualMinutes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledDates: null == scheduledDates
                ? _value.scheduledDates
                : scheduledDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            completedDates: null == completedDates
                ? _value.completedDates
                : completedDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            categoryIds: null == categoryIds
                ? _value.categoryIds
                : categoryIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            estimatedMinutes: freezed == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            actualMinutes: freezed == actualMinutes
                ? _value.actualMinutes
                : actualMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoEntityImplCopyWith<$Res>
    implements $TodoEntityCopyWith<$Res> {
  factory _$$TodoEntityImplCopyWith(
    _$TodoEntityImpl value,
    $Res Function(_$TodoEntityImpl) then,
  ) = __$$TodoEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    List<DateTime> scheduledDates,
    List<DateTime> completedDates,
    List<String> categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TodoEntityImplCopyWithImpl<$Res>
    extends _$TodoEntityCopyWithImpl<$Res, _$TodoEntityImpl>
    implements _$$TodoEntityImplCopyWith<$Res> {
  __$$TodoEntityImplCopyWithImpl(
    _$TodoEntityImpl _value,
    $Res Function(_$TodoEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? scheduledDates = null,
    Object? completedDates = null,
    Object? categoryIds = null,
    Object? estimatedMinutes = freezed,
    Object? actualMinutes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TodoEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledDates: null == scheduledDates
            ? _value._scheduledDates
            : scheduledDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        completedDates: null == completedDates
            ? _value._completedDates
            : completedDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        categoryIds: null == categoryIds
            ? _value._categoryIds
            : categoryIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        estimatedMinutes: freezed == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        actualMinutes: freezed == actualMinutes
            ? _value.actualMinutes
            : actualMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$TodoEntityImpl extends _TodoEntity {
  const _$TodoEntityImpl({
    required this.id,
    required this.title,
    final List<DateTime> scheduledDates = const [],
    final List<DateTime> completedDates = const [],
    final List<String> categoryIds = const [],
    this.estimatedMinutes,
    this.actualMinutes,
    required this.createdAt,
    required this.updatedAt,
  }) : _scheduledDates = scheduledDates,
       _completedDates = completedDates,
       _categoryIds = categoryIds,
       super._();

  @override
  final String id;
  @override
  final String title;
  final List<DateTime> _scheduledDates;
  @override
  @JsonKey()
  List<DateTime> get scheduledDates {
    if (_scheduledDates is EqualUnmodifiableListView) return _scheduledDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduledDates);
  }

  final List<DateTime> _completedDates;
  @override
  @JsonKey()
  List<DateTime> get completedDates {
    if (_completedDates is EqualUnmodifiableListView) return _completedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedDates);
  }

  final List<String> _categoryIds;
  @override
  @JsonKey()
  List<String> get categoryIds {
    if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryIds);
  }

  @override
  final int? estimatedMinutes;
  @override
  final int? actualMinutes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TodoEntity(id: $id, title: $title, scheduledDates: $scheduledDates, completedDates: $completedDates, categoryIds: $categoryIds, estimatedMinutes: $estimatedMinutes, actualMinutes: $actualMinutes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._scheduledDates,
              _scheduledDates,
            ) &&
            const DeepCollectionEquality().equals(
              other._completedDates,
              _completedDates,
            ) &&
            const DeepCollectionEquality().equals(
              other._categoryIds,
              _categoryIds,
            ) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.actualMinutes, actualMinutes) ||
                other.actualMinutes == actualMinutes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    const DeepCollectionEquality().hash(_scheduledDates),
    const DeepCollectionEquality().hash(_completedDates),
    const DeepCollectionEquality().hash(_categoryIds),
    estimatedMinutes,
    actualMinutes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoEntityImplCopyWith<_$TodoEntityImpl> get copyWith =>
      __$$TodoEntityImplCopyWithImpl<_$TodoEntityImpl>(this, _$identity);
}

abstract class _TodoEntity extends TodoEntity {
  const factory _TodoEntity({
    required final String id,
    required final String title,
    final List<DateTime> scheduledDates,
    final List<DateTime> completedDates,
    final List<String> categoryIds,
    final int? estimatedMinutes,
    final int? actualMinutes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TodoEntityImpl;
  const _TodoEntity._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  List<DateTime> get scheduledDates;
  @override
  List<DateTime> get completedDates;
  @override
  List<String> get categoryIds;
  @override
  int? get estimatedMinutes;
  @override
  int? get actualMinutes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TodoEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoEntityImplCopyWith<_$TodoEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
