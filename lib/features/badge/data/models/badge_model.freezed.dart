// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BadgeUnlockModel _$BadgeUnlockModelFromJson(Map<String, dynamic> json) {
  return _BadgeUnlockModel.fromJson(json);
}

/// @nodoc
mixin _$BadgeUnlockModel {
  @JsonKey(name: 'badge_id')
  String get badgeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'unlocked_at')
  DateTime get unlockedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_new')
  bool get isNew => throw _privateConstructorUsedError;

  /// Serializes this BadgeUnlockModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BadgeUnlockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeUnlockModelCopyWith<BadgeUnlockModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeUnlockModelCopyWith<$Res> {
  factory $BadgeUnlockModelCopyWith(
    BadgeUnlockModel value,
    $Res Function(BadgeUnlockModel) then,
  ) = _$BadgeUnlockModelCopyWithImpl<$Res, BadgeUnlockModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'badge_id') String badgeId,
    @JsonKey(name: 'unlocked_at') DateTime unlockedAt,
    @JsonKey(name: 'is_new') bool isNew,
  });
}

/// @nodoc
class _$BadgeUnlockModelCopyWithImpl<$Res, $Val extends BadgeUnlockModel>
    implements $BadgeUnlockModelCopyWith<$Res> {
  _$BadgeUnlockModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeUnlockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? unlockedAt = null,
    Object? isNew = null,
  }) {
    return _then(
      _value.copyWith(
            badgeId: null == badgeId
                ? _value.badgeId
                : badgeId // ignore: cast_nullable_to_non_nullable
                      as String,
            unlockedAt: null == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isNew: null == isNew
                ? _value.isNew
                : isNew // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeUnlockModelImplCopyWith<$Res>
    implements $BadgeUnlockModelCopyWith<$Res> {
  factory _$$BadgeUnlockModelImplCopyWith(
    _$BadgeUnlockModelImpl value,
    $Res Function(_$BadgeUnlockModelImpl) then,
  ) = __$$BadgeUnlockModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'badge_id') String badgeId,
    @JsonKey(name: 'unlocked_at') DateTime unlockedAt,
    @JsonKey(name: 'is_new') bool isNew,
  });
}

/// @nodoc
class __$$BadgeUnlockModelImplCopyWithImpl<$Res>
    extends _$BadgeUnlockModelCopyWithImpl<$Res, _$BadgeUnlockModelImpl>
    implements _$$BadgeUnlockModelImplCopyWith<$Res> {
  __$$BadgeUnlockModelImplCopyWithImpl(
    _$BadgeUnlockModelImpl _value,
    $Res Function(_$BadgeUnlockModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeUnlockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? unlockedAt = null,
    Object? isNew = null,
  }) {
    return _then(
      _$BadgeUnlockModelImpl(
        badgeId: null == badgeId
            ? _value.badgeId
            : badgeId // ignore: cast_nullable_to_non_nullable
                  as String,
        unlockedAt: null == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isNew: null == isNew
            ? _value.isNew
            : isNew // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeUnlockModelImpl implements _BadgeUnlockModel {
  const _$BadgeUnlockModelImpl({
    @JsonKey(name: 'badge_id') required this.badgeId,
    @JsonKey(name: 'unlocked_at') required this.unlockedAt,
    @JsonKey(name: 'is_new') this.isNew = true,
  });

  factory _$BadgeUnlockModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeUnlockModelImplFromJson(json);

  @override
  @JsonKey(name: 'badge_id')
  final String badgeId;
  @override
  @JsonKey(name: 'unlocked_at')
  final DateTime unlockedAt;
  @override
  @JsonKey(name: 'is_new')
  final bool isNew;

  @override
  String toString() {
    return 'BadgeUnlockModel(badgeId: $badgeId, unlockedAt: $unlockedAt, isNew: $isNew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeUnlockModelImpl &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.isNew, isNew) || other.isNew == isNew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, badgeId, unlockedAt, isNew);

  /// Create a copy of BadgeUnlockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeUnlockModelImplCopyWith<_$BadgeUnlockModelImpl> get copyWith =>
      __$$BadgeUnlockModelImplCopyWithImpl<_$BadgeUnlockModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeUnlockModelImplToJson(this);
  }
}

abstract class _BadgeUnlockModel implements BadgeUnlockModel {
  const factory _BadgeUnlockModel({
    @JsonKey(name: 'badge_id') required final String badgeId,
    @JsonKey(name: 'unlocked_at') required final DateTime unlockedAt,
    @JsonKey(name: 'is_new') final bool isNew,
  }) = _$BadgeUnlockModelImpl;

  factory _BadgeUnlockModel.fromJson(Map<String, dynamic> json) =
      _$BadgeUnlockModelImpl.fromJson;

  @override
  @JsonKey(name: 'badge_id')
  String get badgeId;
  @override
  @JsonKey(name: 'unlocked_at')
  DateTime get unlockedAt;
  @override
  @JsonKey(name: 'is_new')
  bool get isNew;

  /// Create a copy of BadgeUnlockModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeUnlockModelImplCopyWith<_$BadgeUnlockModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
