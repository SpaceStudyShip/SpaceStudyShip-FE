// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FuelTransactionModel _$FuelTransactionModelFromJson(Map<String, dynamic> json) {
  return _FuelTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$FuelTransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_id')
  String? get referenceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_after')
  int get balanceAfter => throw _privateConstructorUsedError;
  @SafeDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FuelTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionModelCopyWith<FuelTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionModelCopyWith<$Res> {
  factory $FuelTransactionModelCopyWith(
    FuelTransactionModel value,
    $Res Function(FuelTransactionModel) then,
  ) = _$FuelTransactionModelCopyWithImpl<$Res, FuelTransactionModel>;
  @useResult
  $Res call({
    String id,
    String type,
    int amount,
    String reason,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'balance_after') int balanceAfter,
    @SafeDateTimeConverter() @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$FuelTransactionModelCopyWithImpl<
  $Res,
  $Val extends FuelTransactionModel
>
    implements $FuelTransactionModelCopyWith<$Res> {
  _$FuelTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionModel
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
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$FuelTransactionModelImplCopyWith<$Res>
    implements $FuelTransactionModelCopyWith<$Res> {
  factory _$$FuelTransactionModelImplCopyWith(
    _$FuelTransactionModelImpl value,
    $Res Function(_$FuelTransactionModelImpl) then,
  ) = __$$FuelTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    int amount,
    String reason,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'balance_after') int balanceAfter,
    @SafeDateTimeConverter() @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$FuelTransactionModelImplCopyWithImpl<$Res>
    extends _$FuelTransactionModelCopyWithImpl<$Res, _$FuelTransactionModelImpl>
    implements _$$FuelTransactionModelImplCopyWith<$Res> {
  __$$FuelTransactionModelImplCopyWithImpl(
    _$FuelTransactionModelImpl _value,
    $Res Function(_$FuelTransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionModel
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
      _$FuelTransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
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
@JsonSerializable()
class _$FuelTransactionModelImpl implements _FuelTransactionModel {
  const _$FuelTransactionModelImpl({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    @JsonKey(name: 'reference_id') this.referenceId,
    @JsonKey(name: 'balance_after') required this.balanceAfter,
    @SafeDateTimeConverter()
    @JsonKey(name: 'created_at')
    required this.createdAt,
  });

  factory _$FuelTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FuelTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final int amount;
  @override
  final String reason;
  @override
  @JsonKey(name: 'reference_id')
  final String? referenceId;
  @override
  @JsonKey(name: 'balance_after')
  final int balanceAfter;
  @override
  @SafeDateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'FuelTransactionModel(id: $id, type: $type, amount: $amount, reason: $reason, referenceId: $referenceId, balanceAfter: $balanceAfter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FuelTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionModelImplCopyWith<_$FuelTransactionModelImpl>
  get copyWith =>
      __$$FuelTransactionModelImplCopyWithImpl<_$FuelTransactionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelTransactionModelImplToJson(this);
  }
}

abstract class _FuelTransactionModel implements FuelTransactionModel {
  const factory _FuelTransactionModel({
    required final String id,
    required final String type,
    required final int amount,
    required final String reason,
    @JsonKey(name: 'reference_id') final String? referenceId,
    @JsonKey(name: 'balance_after') required final int balanceAfter,
    @SafeDateTimeConverter()
    @JsonKey(name: 'created_at')
    required final DateTime createdAt,
  }) = _$FuelTransactionModelImpl;

  factory _FuelTransactionModel.fromJson(Map<String, dynamic> json) =
      _$FuelTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  int get amount;
  @override
  String get reason;
  @override
  @JsonKey(name: 'reference_id')
  String? get referenceId;
  @override
  @JsonKey(name: 'balance_after')
  int get balanceAfter;
  @override
  @SafeDateTimeConverter()
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of FuelTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionModelImplCopyWith<_$FuelTransactionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
