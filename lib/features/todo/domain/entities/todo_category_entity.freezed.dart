// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodoCategoryEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get emoji => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of TodoCategoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoCategoryEntityCopyWith<TodoCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoCategoryEntityCopyWith<$Res> {
  factory $TodoCategoryEntityCopyWith(
    TodoCategoryEntity value,
    $Res Function(TodoCategoryEntity) then,
  ) = _$TodoCategoryEntityCopyWithImpl<$Res, TodoCategoryEntity>;
  @useResult
  $Res call({String id, String name, String? emoji, DateTime createdAt});
}

/// @nodoc
class _$TodoCategoryEntityCopyWithImpl<$Res, $Val extends TodoCategoryEntity>
    implements $TodoCategoryEntityCopyWith<$Res> {
  _$TodoCategoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoCategoryEntity
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
abstract class _$$TodoCategoryEntityImplCopyWith<$Res>
    implements $TodoCategoryEntityCopyWith<$Res> {
  factory _$$TodoCategoryEntityImplCopyWith(
    _$TodoCategoryEntityImpl value,
    $Res Function(_$TodoCategoryEntityImpl) then,
  ) = __$$TodoCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? emoji, DateTime createdAt});
}

/// @nodoc
class __$$TodoCategoryEntityImplCopyWithImpl<$Res>
    extends _$TodoCategoryEntityCopyWithImpl<$Res, _$TodoCategoryEntityImpl>
    implements _$$TodoCategoryEntityImplCopyWith<$Res> {
  __$$TodoCategoryEntityImplCopyWithImpl(
    _$TodoCategoryEntityImpl _value,
    $Res Function(_$TodoCategoryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoCategoryEntity
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
      _$TodoCategoryEntityImpl(
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

class _$TodoCategoryEntityImpl implements _TodoCategoryEntity {
  const _$TodoCategoryEntityImpl({
    required this.id,
    required this.name,
    this.emoji,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String? emoji;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TodoCategoryEntity(id: $id, name: $name, emoji: $emoji, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji, createdAt);

  /// Create a copy of TodoCategoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoCategoryEntityImplCopyWith<_$TodoCategoryEntityImpl> get copyWith =>
      __$$TodoCategoryEntityImplCopyWithImpl<_$TodoCategoryEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _TodoCategoryEntity implements TodoCategoryEntity {
  const factory _TodoCategoryEntity({
    required final String id,
    required final String name,
    final String? emoji,
    required final DateTime createdAt,
  }) = _$TodoCategoryEntityImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get emoji;
  @override
  DateTime get createdAt;

  /// Create a copy of TodoCategoryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoCategoryEntityImplCopyWith<_$TodoCategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
