// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthResultEntity {
  /// 회원 ID (백엔드 식별자, int64)
  ///
  /// 게스트 모드일 경우 `-1`. 실제 회원 식별이 필요한 곳에서는
  /// [isGuest] 플래그를 먼저 확인해야 합니다.
  int get memberId => throw _privateConstructorUsedError;

  /// 닉네임 (서버에서 자동 생성 또는 사용자 설정)
  String get nickname => throw _privateConstructorUsedError;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  bool get isNewMember => throw _privateConstructorUsedError;

  /// 게스트 모드 여부
  ///
  /// true일 경우 데이터가 서버에 저장되지 않으며,
  /// 소셜 탭 접근이 제한됩니다.
  bool get isGuest => throw _privateConstructorUsedError;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultEntityCopyWith<AuthResultEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultEntityCopyWith<$Res> {
  factory $AuthResultEntityCopyWith(
    AuthResultEntity value,
    $Res Function(AuthResultEntity) then,
  ) = _$AuthResultEntityCopyWithImpl<$Res, AuthResultEntity>;
  @useResult
  $Res call({int memberId, String nickname, bool isNewMember, bool isGuest});
}

/// @nodoc
class _$AuthResultEntityCopyWithImpl<$Res, $Val extends AuthResultEntity>
    implements $AuthResultEntityCopyWith<$Res> {
  _$AuthResultEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? nickname = null,
    Object? isNewMember = null,
    Object? isGuest = null,
  }) {
    return _then(
      _value.copyWith(
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as int,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            isNewMember: null == isNewMember
                ? _value.isNewMember
                : isNewMember // ignore: cast_nullable_to_non_nullable
                      as bool,
            isGuest: null == isGuest
                ? _value.isGuest
                : isGuest // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthResultEntityImplCopyWith<$Res>
    implements $AuthResultEntityCopyWith<$Res> {
  factory _$$AuthResultEntityImplCopyWith(
    _$AuthResultEntityImpl value,
    $Res Function(_$AuthResultEntityImpl) then,
  ) = __$$AuthResultEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int memberId, String nickname, bool isNewMember, bool isGuest});
}

/// @nodoc
class __$$AuthResultEntityImplCopyWithImpl<$Res>
    extends _$AuthResultEntityCopyWithImpl<$Res, _$AuthResultEntityImpl>
    implements _$$AuthResultEntityImplCopyWith<$Res> {
  __$$AuthResultEntityImplCopyWithImpl(
    _$AuthResultEntityImpl _value,
    $Res Function(_$AuthResultEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? nickname = null,
    Object? isNewMember = null,
    Object? isGuest = null,
  }) {
    return _then(
      _$AuthResultEntityImpl(
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as int,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        isNewMember: null == isNewMember
            ? _value.isNewMember
            : isNewMember // ignore: cast_nullable_to_non_nullable
                  as bool,
        isGuest: null == isGuest
            ? _value.isGuest
            : isGuest // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AuthResultEntityImpl implements _AuthResultEntity {
  const _$AuthResultEntityImpl({
    required this.memberId,
    required this.nickname,
    required this.isNewMember,
    this.isGuest = false,
  });

  /// 회원 ID (백엔드 식별자, int64)
  ///
  /// 게스트 모드일 경우 `-1`. 실제 회원 식별이 필요한 곳에서는
  /// [isGuest] 플래그를 먼저 확인해야 합니다.
  @override
  final int memberId;

  /// 닉네임 (서버에서 자동 생성 또는 사용자 설정)
  @override
  final String nickname;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  @override
  final bool isNewMember;

  /// 게스트 모드 여부
  ///
  /// true일 경우 데이터가 서버에 저장되지 않으며,
  /// 소셜 탭 접근이 제한됩니다.
  @override
  @JsonKey()
  final bool isGuest;

  @override
  String toString() {
    return 'AuthResultEntity(memberId: $memberId, nickname: $nickname, isNewMember: $isNewMember, isGuest: $isGuest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultEntityImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.isNewMember, isNewMember) ||
                other.isNewMember == isNewMember) &&
            (identical(other.isGuest, isGuest) || other.isGuest == isGuest));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, nickname, isNewMember, isGuest);

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultEntityImplCopyWith<_$AuthResultEntityImpl> get copyWith =>
      __$$AuthResultEntityImplCopyWithImpl<_$AuthResultEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AuthResultEntity implements AuthResultEntity {
  const factory _AuthResultEntity({
    required final int memberId,
    required final String nickname,
    required final bool isNewMember,
    final bool isGuest,
  }) = _$AuthResultEntityImpl;

  /// 회원 ID (백엔드 식별자, int64)
  ///
  /// 게스트 모드일 경우 `-1`. 실제 회원 식별이 필요한 곳에서는
  /// [isGuest] 플래그를 먼저 확인해야 합니다.
  @override
  int get memberId;

  /// 닉네임 (서버에서 자동 생성 또는 사용자 설정)
  @override
  String get nickname;

  /// 신규 회원 여부
  ///
  /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
  @override
  bool get isNewMember;

  /// 게스트 모드 여부
  ///
  /// true일 경우 데이터가 서버에 저장되지 않으며,
  /// 소셜 탭 접근이 제한됩니다.
  @override
  bool get isGuest;

  /// Create a copy of AuthResultEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultEntityImplCopyWith<_$AuthResultEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
