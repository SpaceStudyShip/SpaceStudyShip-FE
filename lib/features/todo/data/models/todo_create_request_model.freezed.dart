// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_create_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoCreateRequestModel {
  String? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<String>? get categoryIds => throw _privateConstructorUsedError;
  int? get estimatedMinutes => throw _privateConstructorUsedError;
  List<String>? get scheduledDates => throw _privateConstructorUsedError;

  /// Serializes this TodoCreateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoCreateRequestModelCopyWith<TodoCreateRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoCreateRequestModelCopyWith<$Res> {
  factory $TodoCreateRequestModelCopyWith(
    TodoCreateRequestModel value,
    $Res Function(TodoCreateRequestModel) then,
  ) = _$TodoCreateRequestModelCopyWithImpl<$Res, TodoCreateRequestModel>;
  @useResult
  $Res call({
    String? id,
    String title,
    List<String>? categoryIds,
    int? estimatedMinutes,
    List<String>? scheduledDates,
  });
}

/// @nodoc
class _$TodoCreateRequestModelCopyWithImpl<
  $Res,
  $Val extends TodoCreateRequestModel
>
    implements $TodoCreateRequestModelCopyWith<$Res> {
  _$TodoCreateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? categoryIds = freezed,
    Object? estimatedMinutes = freezed,
    Object? scheduledDates = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryIds: freezed == categoryIds
                ? _value.categoryIds
                : categoryIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            estimatedMinutes: freezed == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            scheduledDates: freezed == scheduledDates
                ? _value.scheduledDates
                : scheduledDates // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoCreateRequestModelImplCopyWith<$Res>
    implements $TodoCreateRequestModelCopyWith<$Res> {
  factory _$$TodoCreateRequestModelImplCopyWith(
    _$TodoCreateRequestModelImpl value,
    $Res Function(_$TodoCreateRequestModelImpl) then,
  ) = __$$TodoCreateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String title,
    List<String>? categoryIds,
    int? estimatedMinutes,
    List<String>? scheduledDates,
  });
}

/// @nodoc
class __$$TodoCreateRequestModelImplCopyWithImpl<$Res>
    extends
        _$TodoCreateRequestModelCopyWithImpl<$Res, _$TodoCreateRequestModelImpl>
    implements _$$TodoCreateRequestModelImplCopyWith<$Res> {
  __$$TodoCreateRequestModelImplCopyWithImpl(
    _$TodoCreateRequestModelImpl _value,
    $Res Function(_$TodoCreateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? categoryIds = freezed,
    Object? estimatedMinutes = freezed,
    Object? scheduledDates = freezed,
  }) {
    return _then(
      _$TodoCreateRequestModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryIds: freezed == categoryIds
            ? _value._categoryIds
            : categoryIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        estimatedMinutes: freezed == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        scheduledDates: freezed == scheduledDates
            ? _value._scheduledDates
            : scheduledDates // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$TodoCreateRequestModelImpl implements _TodoCreateRequestModel {
  const _$TodoCreateRequestModelImpl({
    this.id,
    required this.title,
    final List<String>? categoryIds,
    this.estimatedMinutes,
    final List<String>? scheduledDates,
  }) : _categoryIds = categoryIds,
       _scheduledDates = scheduledDates;

  @override
  final String? id;
  @override
  final String title;
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
  final List<String>? _scheduledDates;
  @override
  List<String>? get scheduledDates {
    final value = _scheduledDates;
    if (value == null) return null;
    if (_scheduledDates is EqualUnmodifiableListView) return _scheduledDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TodoCreateRequestModel(id: $id, title: $title, categoryIds: $categoryIds, estimatedMinutes: $estimatedMinutes, scheduledDates: $scheduledDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoCreateRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._categoryIds,
              _categoryIds,
            ) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality().equals(
              other._scheduledDates,
              _scheduledDates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    const DeepCollectionEquality().hash(_categoryIds),
    estimatedMinutes,
    const DeepCollectionEquality().hash(_scheduledDates),
  );

  /// Create a copy of TodoCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoCreateRequestModelImplCopyWith<_$TodoCreateRequestModelImpl>
  get copyWith =>
      __$$TodoCreateRequestModelImplCopyWithImpl<_$TodoCreateRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoCreateRequestModelImplToJson(this);
  }
}

abstract class _TodoCreateRequestModel implements TodoCreateRequestModel {
  const factory _TodoCreateRequestModel({
    final String? id,
    required final String title,
    final List<String>? categoryIds,
    final int? estimatedMinutes,
    final List<String>? scheduledDates,
  }) = _$TodoCreateRequestModelImpl;

  @override
  String? get id;
  @override
  String get title;
  @override
  List<String>? get categoryIds;
  @override
  int? get estimatedMinutes;
  @override
  List<String>? get scheduledDates;

  /// Create a copy of TodoCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoCreateRequestModelImplCopyWith<_$TodoCreateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
