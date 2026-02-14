// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TodoCategoryModel _$TodoCategoryModelFromJson(Map<String, dynamic> json) {
  return _TodoCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$TodoCategoryModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get emoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TodoCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoCategoryModelCopyWith<TodoCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoCategoryModelCopyWith<$Res> {
  factory $TodoCategoryModelCopyWith(
    TodoCategoryModel value,
    $Res Function(TodoCategoryModel) then,
  ) = _$TodoCategoryModelCopyWithImpl<$Res, TodoCategoryModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? emoji,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$TodoCategoryModelCopyWithImpl<$Res, $Val extends TodoCategoryModel>
    implements $TodoCategoryModelCopyWith<$Res> {
  _$TodoCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: freezed == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoCategoryModelImplCopyWith<$Res>
    implements $TodoCategoryModelCopyWith<$Res> {
  factory _$$TodoCategoryModelImplCopyWith(
    _$TodoCategoryModelImpl value,
    $Res Function(_$TodoCategoryModelImpl) then,
  ) = __$$TodoCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? emoji,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$TodoCategoryModelImplCopyWithImpl<$Res>
    extends _$TodoCategoryModelCopyWithImpl<$Res, _$TodoCategoryModelImpl>
    implements _$$TodoCategoryModelImplCopyWith<$Res> {
  __$$TodoCategoryModelImplCopyWithImpl(
    _$TodoCategoryModelImpl _value,
    $Res Function(_$TodoCategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TodoCategoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: freezed == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodoCategoryModelImpl implements _TodoCategoryModel {
  const _$TodoCategoryModelImpl({
    required this.id,
    required this.name,
    this.emoji,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$TodoCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodoCategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? emoji;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'TodoCategoryModel(id: $id, name: $name, emoji: $emoji, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji, createdAt);

  /// Create a copy of TodoCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoCategoryModelImplCopyWith<_$TodoCategoryModelImpl> get copyWith =>
      __$$TodoCategoryModelImplCopyWithImpl<_$TodoCategoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoCategoryModelImplToJson(this);
  }
}

abstract class _TodoCategoryModel implements TodoCategoryModel {
  const factory _TodoCategoryModel({
    required final String id,
    required final String name,
    final String? emoji,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$TodoCategoryModelImpl;

  factory _TodoCategoryModel.fromJson(Map<String, dynamic> json) =
      _$TodoCategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get emoji;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TodoCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoCategoryModelImplCopyWith<_$TodoCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
