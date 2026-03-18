// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking_entry_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RankingEntryEntity {
  int get rank => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get studyTimeMinutes => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;

  /// Create a copy of RankingEntryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingEntryEntityCopyWith<RankingEntryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingEntryEntityCopyWith<$Res> {
  factory $RankingEntryEntityCopyWith(
    RankingEntryEntity value,
    $Res Function(RankingEntryEntity) then,
  ) = _$RankingEntryEntityCopyWithImpl<$Res, RankingEntryEntity>;
  @useResult
  $Res call({
    int rank,
    String userId,
    String name,
    String? avatarUrl,
    int studyTimeMinutes,
    bool isMe,
  });
}

/// @nodoc
class _$RankingEntryEntityCopyWithImpl<$Res, $Val extends RankingEntryEntity>
    implements $RankingEntryEntityCopyWith<$Res> {
  _$RankingEntryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingEntryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? studyTimeMinutes = null,
    Object? isMe = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            studyTimeMinutes: null == studyTimeMinutes
                ? _value.studyTimeMinutes
                : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            isMe: null == isMe
                ? _value.isMe
                : isMe // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RankingEntryEntityImplCopyWith<$Res>
    implements $RankingEntryEntityCopyWith<$Res> {
  factory _$$RankingEntryEntityImplCopyWith(
    _$RankingEntryEntityImpl value,
    $Res Function(_$RankingEntryEntityImpl) then,
  ) = __$$RankingEntryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rank,
    String userId,
    String name,
    String? avatarUrl,
    int studyTimeMinutes,
    bool isMe,
  });
}

/// @nodoc
class __$$RankingEntryEntityImplCopyWithImpl<$Res>
    extends _$RankingEntryEntityCopyWithImpl<$Res, _$RankingEntryEntityImpl>
    implements _$$RankingEntryEntityImplCopyWith<$Res> {
  __$$RankingEntryEntityImplCopyWithImpl(
    _$RankingEntryEntityImpl _value,
    $Res Function(_$RankingEntryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RankingEntryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? studyTimeMinutes = null,
    Object? isMe = null,
  }) {
    return _then(
      _$RankingEntryEntityImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        studyTimeMinutes: null == studyTimeMinutes
            ? _value.studyTimeMinutes
            : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        isMe: null == isMe
            ? _value.isMe
            : isMe // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$RankingEntryEntityImpl implements _RankingEntryEntity {
  const _$RankingEntryEntityImpl({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.studyTimeMinutes,
    required this.isMe,
  });

  @override
  final int rank;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final int studyTimeMinutes;
  @override
  final bool isMe;

  @override
  String toString() {
    return 'RankingEntryEntity(rank: $rank, userId: $userId, name: $name, avatarUrl: $avatarUrl, studyTimeMinutes: $studyTimeMinutes, isMe: $isMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingEntryEntityImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.studyTimeMinutes, studyTimeMinutes) ||
                other.studyTimeMinutes == studyTimeMinutes) &&
            (identical(other.isMe, isMe) || other.isMe == isMe));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    rank,
    userId,
    name,
    avatarUrl,
    studyTimeMinutes,
    isMe,
  );

  /// Create a copy of RankingEntryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingEntryEntityImplCopyWith<_$RankingEntryEntityImpl> get copyWith =>
      __$$RankingEntryEntityImplCopyWithImpl<_$RankingEntryEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _RankingEntryEntity implements RankingEntryEntity {
  const factory _RankingEntryEntity({
    required final int rank,
    required final String userId,
    required final String name,
    final String? avatarUrl,
    required final int studyTimeMinutes,
    required final bool isMe,
  }) = _$RankingEntryEntityImpl;

  @override
  int get rank;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  int get studyTimeMinutes;
  @override
  bool get isMe;

  /// Create a copy of RankingEntryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingEntryEntityImplCopyWith<_$RankingEntryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
