// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BadgeEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  BadgeCategory get category => throw _privateConstructorUsedError;
  BadgeRarity get rarity => throw _privateConstructorUsedError;

  /// 해금에 필요한 조건값 (예: 60 = 60분, 7 = 7일)
  int get requiredValue => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;

  /// 해금된 시간
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  /// Create a copy of BadgeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeEntityCopyWith<BadgeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeEntityCopyWith<$Res> {
  factory $BadgeEntityCopyWith(
    BadgeEntity value,
    $Res Function(BadgeEntity) then,
  ) = _$BadgeEntityCopyWithImpl<$Res, BadgeEntity>;
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String description,
    BadgeCategory category,
    BadgeRarity rarity,
    int requiredValue,
    bool isUnlocked,
    DateTime? unlockedAt,
  });
}

/// @nodoc
class _$BadgeEntityCopyWithImpl<$Res, $Val extends BadgeEntity>
    implements $BadgeEntityCopyWith<$Res> {
  _$BadgeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? description = null,
    Object? category = null,
    Object? rarity = null,
    Object? requiredValue = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
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
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as BadgeCategory,
            rarity: null == rarity
                ? _value.rarity
                : rarity // ignore: cast_nullable_to_non_nullable
                      as BadgeRarity,
            requiredValue: null == requiredValue
                ? _value.requiredValue
                : requiredValue // ignore: cast_nullable_to_non_nullable
                      as int,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeEntityImplCopyWith<$Res>
    implements $BadgeEntityCopyWith<$Res> {
  factory _$$BadgeEntityImplCopyWith(
    _$BadgeEntityImpl value,
    $Res Function(_$BadgeEntityImpl) then,
  ) = __$$BadgeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String description,
    BadgeCategory category,
    BadgeRarity rarity,
    int requiredValue,
    bool isUnlocked,
    DateTime? unlockedAt,
  });
}

/// @nodoc
class __$$BadgeEntityImplCopyWithImpl<$Res>
    extends _$BadgeEntityCopyWithImpl<$Res, _$BadgeEntityImpl>
    implements _$$BadgeEntityImplCopyWith<$Res> {
  __$$BadgeEntityImplCopyWithImpl(
    _$BadgeEntityImpl _value,
    $Res Function(_$BadgeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? description = null,
    Object? category = null,
    Object? rarity = null,
    Object? requiredValue = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(
      _$BadgeEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as BadgeCategory,
        rarity: null == rarity
            ? _value.rarity
            : rarity // ignore: cast_nullable_to_non_nullable
                  as BadgeRarity,
        requiredValue: null == requiredValue
            ? _value.requiredValue
            : requiredValue // ignore: cast_nullable_to_non_nullable
                  as int,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BadgeEntityImpl implements _BadgeEntity {
  const _$BadgeEntityImpl({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    required this.rarity,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final String description;
  @override
  final BadgeCategory category;
  @override
  final BadgeRarity rarity;

  /// 해금에 필요한 조건값 (예: 60 = 60분, 7 = 7일)
  @override
  final int requiredValue;
  @override
  @JsonKey()
  final bool isUnlocked;

  /// 해금된 시간
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'BadgeEntity(id: $id, name: $name, icon: $icon, description: $description, category: $category, rarity: $rarity, requiredValue: $requiredValue, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rarity, rarity) || other.rarity == rarity) &&
            (identical(other.requiredValue, requiredValue) ||
                other.requiredValue == requiredValue) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    icon,
    description,
    category,
    rarity,
    requiredValue,
    isUnlocked,
    unlockedAt,
  );

  /// Create a copy of BadgeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeEntityImplCopyWith<_$BadgeEntityImpl> get copyWith =>
      __$$BadgeEntityImplCopyWithImpl<_$BadgeEntityImpl>(this, _$identity);
}

abstract class _BadgeEntity implements BadgeEntity {
  const factory _BadgeEntity({
    required final String id,
    required final String name,
    required final String icon,
    required final String description,
    required final BadgeCategory category,
    required final BadgeRarity rarity,
    required final int requiredValue,
    final bool isUnlocked,
    final DateTime? unlockedAt,
  }) = _$BadgeEntityImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  String get description;
  @override
  BadgeCategory get category;
  @override
  BadgeRarity get rarity;

  /// 해금에 필요한 조건값 (예: 60 = 60분, 7 = 7일)
  @override
  int get requiredValue;
  @override
  bool get isUnlocked;

  /// 해금된 시간
  @override
  DateTime? get unlockedAt;

  /// Create a copy of BadgeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeEntityImplCopyWith<_$BadgeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
