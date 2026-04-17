// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FriendEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  FriendStatus get status => throw _privateConstructorUsedError;
  Duration? get studyDuration => throw _privateConstructorUsedError;
  String? get currentSubject => throw _privateConstructorUsedError;
  Duration? get weeklyStudyDuration => throw _privateConstructorUsedError;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendEntityCopyWith<FriendEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendEntityCopyWith<$Res> {
  factory $FriendEntityCopyWith(
    FriendEntity value,
    $Res Function(FriendEntity) then,
  ) = _$FriendEntityCopyWithImpl<$Res, FriendEntity>;
  @useResult
  $Res call({
    String id,
    String name,
    FriendStatus status,
    Duration? studyDuration,
    String? currentSubject,
    Duration? weeklyStudyDuration,
  });
}

/// @nodoc
class _$FriendEntityCopyWithImpl<$Res, $Val extends FriendEntity>
    implements $FriendEntityCopyWith<$Res> {
  _$FriendEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? studyDuration = freezed,
    Object? currentSubject = freezed,
    Object? weeklyStudyDuration = freezed,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FriendStatus,
            studyDuration: freezed == studyDuration
                ? _value.studyDuration
                : studyDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
            currentSubject: freezed == currentSubject
                ? _value.currentSubject
                : currentSubject // ignore: cast_nullable_to_non_nullable
                      as String?,
            weeklyStudyDuration: freezed == weeklyStudyDuration
                ? _value.weeklyStudyDuration
                : weeklyStudyDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendEntityImplCopyWith<$Res>
    implements $FriendEntityCopyWith<$Res> {
  factory _$$FriendEntityImplCopyWith(
    _$FriendEntityImpl value,
    $Res Function(_$FriendEntityImpl) then,
  ) = __$$FriendEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    FriendStatus status,
    Duration? studyDuration,
    String? currentSubject,
    Duration? weeklyStudyDuration,
  });
}

/// @nodoc
class __$$FriendEntityImplCopyWithImpl<$Res>
    extends _$FriendEntityCopyWithImpl<$Res, _$FriendEntityImpl>
    implements _$$FriendEntityImplCopyWith<$Res> {
  __$$FriendEntityImplCopyWithImpl(
    _$FriendEntityImpl _value,
    $Res Function(_$FriendEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? studyDuration = freezed,
    Object? currentSubject = freezed,
    Object? weeklyStudyDuration = freezed,
  }) {
    return _then(
      _$FriendEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FriendStatus,
        studyDuration: freezed == studyDuration
            ? _value.studyDuration
            : studyDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        currentSubject: freezed == currentSubject
            ? _value.currentSubject
            : currentSubject // ignore: cast_nullable_to_non_nullable
                  as String?,
        weeklyStudyDuration: freezed == weeklyStudyDuration
            ? _value.weeklyStudyDuration
            : weeklyStudyDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
      ),
    );
  }
}

/// @nodoc

class _$FriendEntityImpl implements _FriendEntity {
  const _$FriendEntityImpl({
    required this.id,
    required this.name,
    required this.status,
    this.studyDuration,
    this.currentSubject,
    this.weeklyStudyDuration,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final FriendStatus status;
  @override
  final Duration? studyDuration;
  @override
  final String? currentSubject;
  @override
  final Duration? weeklyStudyDuration;

  @override
  String toString() {
    return 'FriendEntity(id: $id, name: $name, status: $status, studyDuration: $studyDuration, currentSubject: $currentSubject, weeklyStudyDuration: $weeklyStudyDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.studyDuration, studyDuration) ||
                other.studyDuration == studyDuration) &&
            (identical(other.currentSubject, currentSubject) ||
                other.currentSubject == currentSubject) &&
            (identical(other.weeklyStudyDuration, weeklyStudyDuration) ||
                other.weeklyStudyDuration == weeklyStudyDuration));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    status,
    studyDuration,
    currentSubject,
    weeklyStudyDuration,
  );

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendEntityImplCopyWith<_$FriendEntityImpl> get copyWith =>
      __$$FriendEntityImplCopyWithImpl<_$FriendEntityImpl>(this, _$identity);
}

abstract class _FriendEntity implements FriendEntity {
  const factory _FriendEntity({
    required final String id,
    required final String name,
    required final FriendStatus status,
    final Duration? studyDuration,
    final String? currentSubject,
    final Duration? weeklyStudyDuration,
  }) = _$FriendEntityImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  FriendStatus get status;
  @override
  Duration? get studyDuration;
  @override
  String? get currentSubject;
  @override
  Duration? get weeklyStudyDuration;

  /// Create a copy of FriendEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendEntityImplCopyWith<_$FriendEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
