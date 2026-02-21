// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FuelEntity {
  int get currentFuel => throw _privateConstructorUsedError;
  int get totalCharged => throw _privateConstructorUsedError;
  int get totalConsumed => throw _privateConstructorUsedError;
  int get pendingMinutes => throw _privateConstructorUsedError;
  DateTime get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Create a copy of FuelEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelEntityCopyWith<FuelEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelEntityCopyWith<$Res> {
  factory $FuelEntityCopyWith(
    FuelEntity value,
    $Res Function(FuelEntity) then,
  ) = _$FuelEntityCopyWithImpl<$Res, FuelEntity>;
  @useResult
  $Res call({
    int currentFuel,
    int totalCharged,
    int totalConsumed,
    int pendingMinutes,
    DateTime lastUpdatedAt,
  });
}

/// @nodoc
class _$FuelEntityCopyWithImpl<$Res, $Val extends FuelEntity>
    implements $FuelEntityCopyWith<$Res> {
  _$FuelEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentFuel = null,
    Object? totalCharged = null,
    Object? totalConsumed = null,
    Object? pendingMinutes = null,
    Object? lastUpdatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            currentFuel: null == currentFuel
                ? _value.currentFuel
                : currentFuel // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCharged: null == totalCharged
                ? _value.totalCharged
                : totalCharged // ignore: cast_nullable_to_non_nullable
                      as int,
            totalConsumed: null == totalConsumed
                ? _value.totalConsumed
                : totalConsumed // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingMinutes: null == pendingMinutes
                ? _value.pendingMinutes
                : pendingMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUpdatedAt: null == lastUpdatedAt
                ? _value.lastUpdatedAt
                : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FuelEntityImplCopyWith<$Res>
    implements $FuelEntityCopyWith<$Res> {
  factory _$$FuelEntityImplCopyWith(
    _$FuelEntityImpl value,
    $Res Function(_$FuelEntityImpl) then,
  ) = __$$FuelEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentFuel,
    int totalCharged,
    int totalConsumed,
    int pendingMinutes,
    DateTime lastUpdatedAt,
  });
}

/// @nodoc
class __$$FuelEntityImplCopyWithImpl<$Res>
    extends _$FuelEntityCopyWithImpl<$Res, _$FuelEntityImpl>
    implements _$$FuelEntityImplCopyWith<$Res> {
  __$$FuelEntityImplCopyWithImpl(
    _$FuelEntityImpl _value,
    $Res Function(_$FuelEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentFuel = null,
    Object? totalCharged = null,
    Object? totalConsumed = null,
    Object? pendingMinutes = null,
    Object? lastUpdatedAt = null,
  }) {
    return _then(
      _$FuelEntityImpl(
        currentFuel: null == currentFuel
            ? _value.currentFuel
            : currentFuel // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCharged: null == totalCharged
            ? _value.totalCharged
            : totalCharged // ignore: cast_nullable_to_non_nullable
                  as int,
        totalConsumed: null == totalConsumed
            ? _value.totalConsumed
            : totalConsumed // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingMinutes: null == pendingMinutes
            ? _value.pendingMinutes
            : pendingMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUpdatedAt: null == lastUpdatedAt
            ? _value.lastUpdatedAt
            : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$FuelEntityImpl implements _FuelEntity {
  const _$FuelEntityImpl({
    this.currentFuel = 0,
    this.totalCharged = 0,
    this.totalConsumed = 0,
    this.pendingMinutes = 0,
    required this.lastUpdatedAt,
  });

  @override
  @JsonKey()
  final int currentFuel;
  @override
  @JsonKey()
  final int totalCharged;
  @override
  @JsonKey()
  final int totalConsumed;
  @override
  @JsonKey()
  final int pendingMinutes;
  @override
  final DateTime lastUpdatedAt;

  @override
  String toString() {
    return 'FuelEntity(currentFuel: $currentFuel, totalCharged: $totalCharged, totalConsumed: $totalConsumed, pendingMinutes: $pendingMinutes, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelEntityImpl &&
            (identical(other.currentFuel, currentFuel) ||
                other.currentFuel == currentFuel) &&
            (identical(other.totalCharged, totalCharged) ||
                other.totalCharged == totalCharged) &&
            (identical(other.totalConsumed, totalConsumed) ||
                other.totalConsumed == totalConsumed) &&
            (identical(other.pendingMinutes, pendingMinutes) ||
                other.pendingMinutes == pendingMinutes) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentFuel,
    totalCharged,
    totalConsumed,
    pendingMinutes,
    lastUpdatedAt,
  );

  /// Create a copy of FuelEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelEntityImplCopyWith<_$FuelEntityImpl> get copyWith =>
      __$$FuelEntityImplCopyWithImpl<_$FuelEntityImpl>(this, _$identity);
}

abstract class _FuelEntity implements FuelEntity {
  const factory _FuelEntity({
    final int currentFuel,
    final int totalCharged,
    final int totalConsumed,
    final int pendingMinutes,
    required final DateTime lastUpdatedAt,
  }) = _$FuelEntityImpl;

  @override
  int get currentFuel;
  @override
  int get totalCharged;
  @override
  int get totalConsumed;
  @override
  int get pendingMinutes;
  @override
  DateTime get lastUpdatedAt;

  /// Create a copy of FuelEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelEntityImplCopyWith<_$FuelEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
