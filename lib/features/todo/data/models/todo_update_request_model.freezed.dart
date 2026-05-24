// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_update_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoUpdateRequestModel {
  String? get title => throw _privateConstructorUsedError;
  List<String>? get scheduledDates => throw _privateConstructorUsedError;
  List<String>? get completedDates => throw _privateConstructorUsedError;
  List<String>? get categoryIds => throw _privateConstructorUsedError;
  int? get estimatedMinutes => throw _privateConstructorUsedError;
  int? get actualMinutes => throw _privateConstructorUsedError;

  /// Serializes this TodoUpdateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoUpdateRequestModelCopyWith<TodoUpdateRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoUpdateRequestModelCopyWith<$Res> {
  factory $TodoUpdateRequestModelCopyWith(
    TodoUpdateRequestModel value,
    $Res Function(TodoUpdateRequestModel) then,
  ) = _$TodoUpdateRequestModelCopyWithImpl<$Res, TodoUpdateRequestModel>;
  @useResult
  $Res call({
    String? title,
    List<String>? scheduledDates,
    List<String>? completedDates,
    List<String>? categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
  });
}

/// @nodoc
class _$TodoUpdateRequestModelCopyWithImpl<
  $Res,
  $Val extends TodoUpdateRequestModel
>
    implements $TodoUpdateRequestModelCopyWith<$Res> {
  _$TodoUpdateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? scheduledDates = freezed,
    Object? completedDates = freezed,
    Object? categoryIds = freezed,
    Object? estimatedMinutes = freezed,
    Object? actualMinutes = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledDates: freezed == scheduledDates
                ? _value.scheduledDates
                : scheduledDates // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            completedDates: freezed == completedDates
                ? _value.completedDates
                : completedDates // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            categoryIds: freezed == categoryIds
                ? _value.categoryIds
                : categoryIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            estimatedMinutes: freezed == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            actualMinutes: freezed == actualMinutes
                ? _value.actualMinutes
                : actualMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoUpdateRequestModelImplCopyWith<$Res>
    implements $TodoUpdateRequestModelCopyWith<$Res> {
  factory _$$TodoUpdateRequestModelImplCopyWith(
    _$TodoUpdateRequestModelImpl value,
    $Res Function(_$TodoUpdateRequestModelImpl) then,
  ) = __$$TodoUpdateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? title,
    List<String>? scheduledDates,
    List<String>? completedDates,
    List<String>? categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
  });
}

/// @nodoc
class __$$TodoUpdateRequestModelImplCopyWithImpl<$Res>
    extends
        _$TodoUpdateRequestModelCopyWithImpl<$Res, _$TodoUpdateRequestModelImpl>
    implements _$$TodoUpdateRequestModelImplCopyWith<$Res> {
  __$$TodoUpdateRequestModelImplCopyWithImpl(
    _$TodoUpdateRequestModelImpl _value,
    $Res Function(_$TodoUpdateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? scheduledDates = freezed,
    Object? completedDates = freezed,
    Object? categoryIds = freezed,
    Object? estimatedMinutes = freezed,
    Object? actualMinutes = freezed,
  }) {
    return _then(
      _$TodoUpdateRequestModelImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledDates: freezed == scheduledDates
            ? _value._scheduledDates
            : scheduledDates // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        completedDates: freezed == completedDates
            ? _value._completedDates
            : completedDates // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        categoryIds: freezed == categoryIds
            ? _value._categoryIds
            : categoryIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        estimatedMinutes: freezed == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        actualMinutes: freezed == actualMinutes
            ? _value.actualMinutes
            : actualMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$TodoUpdateRequestModelImpl implements _TodoUpdateRequestModel {
  const _$TodoUpdateRequestModelImpl({
    this.title,
    final List<String>? scheduledDates,
    final List<String>? completedDates,
    final List<String>? categoryIds,
    this.estimatedMinutes,
    this.actualMinutes,
  }) : _scheduledDates = scheduledDates,
       _completedDates = completedDates,
       _categoryIds = categoryIds;

  @override
  final String? title;
  final List<String>? _scheduledDates;
  @override
  List<String>? get scheduledDates {
    final value = _scheduledDates;
    if (value == null) return null;
    if (_scheduledDates is EqualUnmodifiableListView) return _scheduledDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _completedDates;
  @override
  List<String>? get completedDates {
    final value = _completedDates;
    if (value == null) return null;
    if (_completedDates is EqualUnmodifiableListView) return _completedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _categoryIds;
  @override
  List<String>? get categoryIds {
    final value = _categoryIds;
    if (value == null) return null;
    if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? estimatedMinutes;
  @override
  final int? actualMinutes;

  @override
  String toString() {
    return 'TodoUpdateRequestModel(title: $title, scheduledDates: $scheduledDates, completedDates: $completedDates, categoryIds: $categoryIds, estimatedMinutes: $estimatedMinutes, actualMinutes: $actualMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoUpdateRequestModelImpl &&
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
                other.actualMinutes == actualMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    const DeepCollectionEquality().hash(_scheduledDates),
    const DeepCollectionEquality().hash(_completedDates),
    const DeepCollectionEquality().hash(_categoryIds),
    estimatedMinutes,
    actualMinutes,
  );

  /// Create a copy of TodoUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoUpdateRequestModelImplCopyWith<_$TodoUpdateRequestModelImpl>
  get copyWith =>
      __$$TodoUpdateRequestModelImplCopyWithImpl<_$TodoUpdateRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoUpdateRequestModelImplToJson(this);
  }
}

abstract class _TodoUpdateRequestModel implements TodoUpdateRequestModel {
  const factory _TodoUpdateRequestModel({
    final String? title,
    final List<String>? scheduledDates,
    final List<String>? completedDates,
    final List<String>? categoryIds,
    final int? estimatedMinutes,
    final int? actualMinutes,
  }) = _$TodoUpdateRequestModelImpl;

  @override
  String? get title;
  @override
  List<String>? get scheduledDates;
  @override
  List<String>? get completedDates;
  @override
  List<String>? get categoryIds;
  @override
  int? get estimatedMinutes;
  @override
  int? get actualMinutes;

  /// Create a copy of TodoUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoUpdateRequestModelImplCopyWith<_$TodoUpdateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
