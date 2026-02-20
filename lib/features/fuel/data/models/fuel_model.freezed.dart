// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FuelModel _$FuelModelFromJson(Map<String, dynamic> json) {
  return _FuelModel.fromJson(json);
}

/// @nodoc
mixin _$FuelModel {
  @JsonKey(name: 'current_fuel')
  int get currentFuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_charged')
  int get totalCharged => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_consumed')
  int get totalConsumed => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_minutes')
  int get pendingMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated_at')
  DateTime get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this FuelModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelModelCopyWith<FuelModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelModelCopyWith<$Res> {
  factory $FuelModelCopyWith(FuelModel value, $Res Function(FuelModel) then) =
      _$FuelModelCopyWithImpl<$Res, FuelModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'current_fuel') int currentFuel,
    @JsonKey(name: 'total_charged') int totalCharged,
    @JsonKey(name: 'total_consumed') int totalConsumed,
    @JsonKey(name: 'pending_minutes') int pendingMinutes,
    @JsonKey(name: 'last_updated_at') DateTime lastUpdatedAt,
  });
}

/// @nodoc
class _$FuelModelCopyWithImpl<$Res, $Val extends FuelModel>
    implements $FuelModelCopyWith<$Res> {
  _$FuelModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelModel
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
abstract class _$$FuelModelImplCopyWith<$Res>
    implements $FuelModelCopyWith<$Res> {
  factory _$$FuelModelImplCopyWith(
    _$FuelModelImpl value,
    $Res Function(_$FuelModelImpl) then,
  ) = __$$FuelModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'current_fuel') int currentFuel,
    @JsonKey(name: 'total_charged') int totalCharged,
    @JsonKey(name: 'total_consumed') int totalConsumed,
    @JsonKey(name: 'pending_minutes') int pendingMinutes,
    @JsonKey(name: 'last_updated_at') DateTime lastUpdatedAt,
  });
}

/// @nodoc
class __$$FuelModelImplCopyWithImpl<$Res>
    extends _$FuelModelCopyWithImpl<$Res, _$FuelModelImpl>
    implements _$$FuelModelImplCopyWith<$Res> {
  __$$FuelModelImplCopyWithImpl(
    _$FuelModelImpl _value,
    $Res Function(_$FuelModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelModel
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
      _$FuelModelImpl(
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
class _$FuelModelImpl implements _FuelModel {
  const _$FuelModelImpl({
    @JsonKey(name: 'current_fuel') this.currentFuel = 0,
    @JsonKey(name: 'total_charged') this.totalCharged = 0,
    @JsonKey(name: 'total_consumed') this.totalConsumed = 0,
    @JsonKey(name: 'pending_minutes') this.pendingMinutes = 0,
    @JsonKey(name: 'last_updated_at') required this.lastUpdatedAt,
  });

  factory _$FuelModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FuelModelImplFromJson(json);

  @override
  @JsonKey(name: 'current_fuel')
  final int currentFuel;
  @override
  @JsonKey(name: 'total_charged')
  final int totalCharged;
  @override
  @JsonKey(name: 'total_consumed')
  final int totalConsumed;
  @override
  @JsonKey(name: 'pending_minutes')
  final int pendingMinutes;
  @override
  @JsonKey(name: 'last_updated_at')
  final DateTime lastUpdatedAt;

  @override
  String toString() {
    return 'FuelModel(currentFuel: $currentFuel, totalCharged: $totalCharged, totalConsumed: $totalConsumed, pendingMinutes: $pendingMinutes, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelModelImpl &&
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

  /// Create a copy of FuelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelModelImplCopyWith<_$FuelModelImpl> get copyWith =>
      __$$FuelModelImplCopyWithImpl<_$FuelModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelModelImplToJson(this);
  }
}

abstract class _FuelModel implements FuelModel {
  const factory _FuelModel({
    @JsonKey(name: 'current_fuel') final int currentFuel,
    @JsonKey(name: 'total_charged') final int totalCharged,
    @JsonKey(name: 'total_consumed') final int totalConsumed,
    @JsonKey(name: 'pending_minutes') final int pendingMinutes,
    @JsonKey(name: 'last_updated_at') required final DateTime lastUpdatedAt,
  }) = _$FuelModelImpl;

  factory _FuelModel.fromJson(Map<String, dynamic> json) =
      _$FuelModelImpl.fromJson;

  @override
  @JsonKey(name: 'current_fuel')
  int get currentFuel;
  @override
  @JsonKey(name: 'total_charged')
  int get totalCharged;
  @override
  @JsonKey(name: 'total_consumed')
  int get totalConsumed;
  @override
  @JsonKey(name: 'pending_minutes')
  int get pendingMinutes;
  @override
  @JsonKey(name: 'last_updated_at')
  DateTime get lastUpdatedAt;

  /// Create a copy of FuelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelModelImplCopyWith<_$FuelModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
