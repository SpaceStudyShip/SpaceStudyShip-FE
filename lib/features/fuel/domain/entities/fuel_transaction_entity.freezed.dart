// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FuelTransactionEntity {
  String get id => throw _privateConstructorUsedError;
  FuelTransactionType get type => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  FuelTransactionReason get reason => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  int get balanceAfter => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionEntityCopyWith<FuelTransactionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionEntityCopyWith<$Res> {
  factory $FuelTransactionEntityCopyWith(
    FuelTransactionEntity value,
    $Res Function(FuelTransactionEntity) then,
  ) = _$FuelTransactionEntityCopyWithImpl<$Res, FuelTransactionEntity>;
  @useResult
  $Res call({
    String id,
    FuelTransactionType type,
    int amount,
    FuelTransactionReason reason,
    String? referenceId,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class _$FuelTransactionEntityCopyWithImpl<
  $Res,
  $Val extends FuelTransactionEntity
>
    implements $FuelTransactionEntityCopyWith<$Res> {
  _$FuelTransactionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? referenceId = freezed,
    Object? balanceAfter = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FuelTransactionType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as FuelTransactionReason,
            referenceId: freezed == referenceId
                ? _value.referenceId
                : referenceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            balanceAfter: null == balanceAfter
                ? _value.balanceAfter
                : balanceAfter // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$FuelTransactionEntityImplCopyWith<$Res>
    implements $FuelTransactionEntityCopyWith<$Res> {
  factory _$$FuelTransactionEntityImplCopyWith(
    _$FuelTransactionEntityImpl value,
    $Res Function(_$FuelTransactionEntityImpl) then,
  ) = __$$FuelTransactionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    FuelTransactionType type,
    int amount,
    FuelTransactionReason reason,
    String? referenceId,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$FuelTransactionEntityImplCopyWithImpl<$Res>
    extends
        _$FuelTransactionEntityCopyWithImpl<$Res, _$FuelTransactionEntityImpl>
    implements _$$FuelTransactionEntityImplCopyWith<$Res> {
  __$$FuelTransactionEntityImplCopyWithImpl(
    _$FuelTransactionEntityImpl _value,
    $Res Function(_$FuelTransactionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? referenceId = freezed,
    Object? balanceAfter = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FuelTransactionEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FuelTransactionType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as FuelTransactionReason,
        referenceId: freezed == referenceId
            ? _value.referenceId
            : referenceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        balanceAfter: null == balanceAfter
            ? _value.balanceAfter
            : balanceAfter // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$FuelTransactionEntityImpl implements _FuelTransactionEntity {
  const _$FuelTransactionEntityImpl({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    this.referenceId,
    required this.balanceAfter,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final FuelTransactionType type;
  @override
  final int amount;
  @override
  final FuelTransactionReason reason;
  @override
  final String? referenceId;
  @override
  final int balanceAfter;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FuelTransactionEntity(id: $id, type: $type, amount: $amount, reason: $reason, referenceId: $referenceId, balanceAfter: $balanceAfter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    amount,
    reason,
    referenceId,
    balanceAfter,
    createdAt,
  );

  /// Create a copy of FuelTransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionEntityImplCopyWith<_$FuelTransactionEntityImpl>
  get copyWith =>
      __$$FuelTransactionEntityImplCopyWithImpl<_$FuelTransactionEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _FuelTransactionEntity implements FuelTransactionEntity {
  const factory _FuelTransactionEntity({
    required final String id,
    required final FuelTransactionType type,
    required final int amount,
    required final FuelTransactionReason reason,
    final String? referenceId,
    required final int balanceAfter,
    required final DateTime createdAt,
  }) = _$FuelTransactionEntityImpl;

  @override
  String get id;
  @override
  FuelTransactionType get type;
  @override
  int get amount;
  @override
  FuelTransactionReason get reason;
  @override
  String? get referenceId;
  @override
  int get balanceAfter;
  @override
  DateTime get createdAt;

  /// Create a copy of FuelTransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionEntityImplCopyWith<_$FuelTransactionEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
