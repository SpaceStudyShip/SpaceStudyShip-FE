// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FuelResponseModel _$FuelResponseModelFromJson(Map<String, dynamic> json) {
  return _FuelResponseModel.fromJson(json);
}

/// @nodoc
mixin _$FuelResponseModel {
  int get currentFuel => throw _privateConstructorUsedError;
  int get totalCharged => throw _privateConstructorUsedError;
  int get totalConsumed => throw _privateConstructorUsedError;
  int get pendingMinutes => throw _privateConstructorUsedError;
  DateTime get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this FuelResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelResponseModelCopyWith<FuelResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelResponseModelCopyWith<$Res> {
  factory $FuelResponseModelCopyWith(
    FuelResponseModel value,
    $Res Function(FuelResponseModel) then,
  ) = _$FuelResponseModelCopyWithImpl<$Res, FuelResponseModel>;
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
class _$FuelResponseModelCopyWithImpl<$Res, $Val extends FuelResponseModel>
    implements $FuelResponseModelCopyWith<$Res> {
  _$FuelResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelResponseModel
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
abstract class _$$FuelResponseModelImplCopyWith<$Res>
    implements $FuelResponseModelCopyWith<$Res> {
  factory _$$FuelResponseModelImplCopyWith(
    _$FuelResponseModelImpl value,
    $Res Function(_$FuelResponseModelImpl) then,
  ) = __$$FuelResponseModelImplCopyWithImpl<$Res>;
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
class __$$FuelResponseModelImplCopyWithImpl<$Res>
    extends _$FuelResponseModelCopyWithImpl<$Res, _$FuelResponseModelImpl>
    implements _$$FuelResponseModelImplCopyWith<$Res> {
  __$$FuelResponseModelImplCopyWithImpl(
    _$FuelResponseModelImpl _value,
    $Res Function(_$FuelResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelResponseModel
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
      _$FuelResponseModelImpl(
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
@JsonSerializable()
class _$FuelResponseModelImpl extends _FuelResponseModel {
  const _$FuelResponseModelImpl({
    required this.currentFuel,
    required this.totalCharged,
    required this.totalConsumed,
    required this.pendingMinutes,
    required this.lastUpdatedAt,
  }) : super._();

  factory _$FuelResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FuelResponseModelImplFromJson(json);

  @override
  final int currentFuel;
  @override
  final int totalCharged;
  @override
  final int totalConsumed;
  @override
  final int pendingMinutes;
  @override
  final DateTime lastUpdatedAt;

  @override
  String toString() {
    return 'FuelResponseModel(currentFuel: $currentFuel, totalCharged: $totalCharged, totalConsumed: $totalConsumed, pendingMinutes: $pendingMinutes, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelResponseModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentFuel,
    totalCharged,
    totalConsumed,
    pendingMinutes,
    lastUpdatedAt,
  );

  /// Create a copy of FuelResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelResponseModelImplCopyWith<_$FuelResponseModelImpl> get copyWith =>
      __$$FuelResponseModelImplCopyWithImpl<_$FuelResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelResponseModelImplToJson(this);
  }
}

abstract class _FuelResponseModel extends FuelResponseModel {
  const factory _FuelResponseModel({
    required final int currentFuel,
    required final int totalCharged,
    required final int totalConsumed,
    required final int pendingMinutes,
    required final DateTime lastUpdatedAt,
  }) = _$FuelResponseModelImpl;
  const _FuelResponseModel._() : super._();

  factory _FuelResponseModel.fromJson(Map<String, dynamic> json) =
      _$FuelResponseModelImpl.fromJson;

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

  /// Create a copy of FuelResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelResponseModelImplCopyWith<_$FuelResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
