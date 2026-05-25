// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FuelTransactionResponseModel _$FuelTransactionResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _FuelTransactionResponseModel.fromJson(json);
}

/// @nodoc
mixin _$FuelTransactionResponseModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
  FuelTransactionTypeWire get type => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
  FuelTransactionReasonWire get reason => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  int get balanceAfter => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FuelTransactionResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionResponseModelCopyWith<FuelTransactionResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionResponseModelCopyWith<$Res> {
  factory $FuelTransactionResponseModelCopyWith(
    FuelTransactionResponseModel value,
    $Res Function(FuelTransactionResponseModel) then,
  ) =
      _$FuelTransactionResponseModelCopyWithImpl<
        $Res,
        FuelTransactionResponseModel
      >;
  @useResult
  $Res call({
    String id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    FuelTransactionTypeWire type,
    int amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    FuelTransactionReasonWire reason,
    String? referenceId,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class _$FuelTransactionResponseModelCopyWithImpl<
  $Res,
  $Val extends FuelTransactionResponseModel
>
    implements $FuelTransactionResponseModelCopyWith<$Res> {
  _$FuelTransactionResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionResponseModel
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
                      as FuelTransactionTypeWire,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as FuelTransactionReasonWire,
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
abstract class _$$FuelTransactionResponseModelImplCopyWith<$Res>
    implements $FuelTransactionResponseModelCopyWith<$Res> {
  factory _$$FuelTransactionResponseModelImplCopyWith(
    _$FuelTransactionResponseModelImpl value,
    $Res Function(_$FuelTransactionResponseModelImpl) then,
  ) = __$$FuelTransactionResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    FuelTransactionTypeWire type,
    int amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    FuelTransactionReasonWire reason,
    String? referenceId,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$FuelTransactionResponseModelImplCopyWithImpl<$Res>
    extends
        _$FuelTransactionResponseModelCopyWithImpl<
          $Res,
          _$FuelTransactionResponseModelImpl
        >
    implements _$$FuelTransactionResponseModelImplCopyWith<$Res> {
  __$$FuelTransactionResponseModelImplCopyWithImpl(
    _$FuelTransactionResponseModelImpl _value,
    $Res Function(_$FuelTransactionResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionResponseModel
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
      _$FuelTransactionResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FuelTransactionTypeWire,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as FuelTransactionReasonWire,
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
class _$FuelTransactionResponseModelImpl extends _FuelTransactionResponseModel {
  const _$FuelTransactionResponseModelImpl({
    required this.id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    required this.type,
    required this.amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    required this.reason,
    this.referenceId,
    required this.balanceAfter,
    required this.createdAt,
  }) : super._();

  factory _$FuelTransactionResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$FuelTransactionResponseModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
  final FuelTransactionTypeWire type;
  @override
  final int amount;
  @override
  @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
  final FuelTransactionReasonWire reason;
  @override
  final String? referenceId;
  @override
  final int balanceAfter;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FuelTransactionResponseModel(id: $id, type: $type, amount: $amount, reason: $reason, referenceId: $referenceId, balanceAfter: $balanceAfter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionResponseModelImpl &&
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

  /// Create a copy of FuelTransactionResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionResponseModelImplCopyWith<
    _$FuelTransactionResponseModelImpl
  >
  get copyWith =>
      __$$FuelTransactionResponseModelImplCopyWithImpl<
        _$FuelTransactionResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelTransactionResponseModelImplToJson(this);
  }
}

abstract class _FuelTransactionResponseModel
    extends FuelTransactionResponseModel {
  const factory _FuelTransactionResponseModel({
    required final String id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    required final FuelTransactionTypeWire type,
    required final int amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    required final FuelTransactionReasonWire reason,
    final String? referenceId,
    required final int balanceAfter,
    required final DateTime createdAt,
  }) = _$FuelTransactionResponseModelImpl;
  const _FuelTransactionResponseModel._() : super._();

  factory _FuelTransactionResponseModel.fromJson(Map<String, dynamic> json) =
      _$FuelTransactionResponseModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
  FuelTransactionTypeWire get type;
  @override
  int get amount;
  @override
  @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
  FuelTransactionReasonWire get reason;
  @override
  String? get referenceId;
  @override
  int get balanceAfter;
  @override
  DateTime get createdAt;

  /// Create a copy of FuelTransactionResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionResponseModelImplCopyWith<
    _$FuelTransactionResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
