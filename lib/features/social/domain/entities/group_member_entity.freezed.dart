// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_member_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GroupMemberEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  OnlineStatus get status => throw _privateConstructorUsedError;
  int get seatIndex => throw _privateConstructorUsedError;

  /// Create a copy of GroupMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupMemberEntityCopyWith<GroupMemberEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberEntityCopyWith<$Res> {
  factory $GroupMemberEntityCopyWith(
    GroupMemberEntity value,
    $Res Function(GroupMemberEntity) then,
  ) = _$GroupMemberEntityCopyWithImpl<$Res, GroupMemberEntity>;
  @useResult
  $Res call({
    String id,
    String name,
    String? avatarUrl,
    OnlineStatus status,
    int seatIndex,
  });
}

/// @nodoc
class _$GroupMemberEntityCopyWithImpl<$Res, $Val extends GroupMemberEntity>
    implements $GroupMemberEntityCopyWith<$Res> {
  _$GroupMemberEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? status = null,
    Object? seatIndex = null,
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
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OnlineStatus,
            seatIndex: null == seatIndex
                ? _value.seatIndex
                : seatIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupMemberEntityImplCopyWith<$Res>
    implements $GroupMemberEntityCopyWith<$Res> {
  factory _$$GroupMemberEntityImplCopyWith(
    _$GroupMemberEntityImpl value,
    $Res Function(_$GroupMemberEntityImpl) then,
  ) = __$$GroupMemberEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? avatarUrl,
    OnlineStatus status,
    int seatIndex,
  });
}

/// @nodoc
class __$$GroupMemberEntityImplCopyWithImpl<$Res>
    extends _$GroupMemberEntityCopyWithImpl<$Res, _$GroupMemberEntityImpl>
    implements _$$GroupMemberEntityImplCopyWith<$Res> {
  __$$GroupMemberEntityImplCopyWithImpl(
    _$GroupMemberEntityImpl _value,
    $Res Function(_$GroupMemberEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? status = null,
    Object? seatIndex = null,
  }) {
    return _then(
      _$GroupMemberEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OnlineStatus,
        seatIndex: null == seatIndex
            ? _value.seatIndex
            : seatIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GroupMemberEntityImpl implements _GroupMemberEntity {
  const _$GroupMemberEntityImpl({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.status,
    required this.seatIndex,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final OnlineStatus status;
  @override
  final int seatIndex;

  @override
  String toString() {
    return 'GroupMemberEntity(id: $id, name: $name, avatarUrl: $avatarUrl, status: $status, seatIndex: $seatIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.seatIndex, seatIndex) ||
                other.seatIndex == seatIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, avatarUrl, status, seatIndex);

  /// Create a copy of GroupMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberEntityImplCopyWith<_$GroupMemberEntityImpl> get copyWith =>
      __$$GroupMemberEntityImplCopyWithImpl<_$GroupMemberEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _GroupMemberEntity implements GroupMemberEntity {
  const factory _GroupMemberEntity({
    required final String id,
    required final String name,
    final String? avatarUrl,
    required final OnlineStatus status,
    required final int seatIndex,
  }) = _$GroupMemberEntityImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  OnlineStatus get status;
  @override
  int get seatIndex;

  /// Create a copy of GroupMemberEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupMemberEntityImplCopyWith<_$GroupMemberEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
