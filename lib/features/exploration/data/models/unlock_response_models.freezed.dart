// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unlock_response_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UnlockedNodeModel _$UnlockedNodeModelFromJson(Map<String, dynamic> json) {
  return _UnlockedNodeModel.fromJson(json);
}

/// @nodoc
mixin _$UnlockedNodeModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  bool get isCleared => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  /// Serializes this UnlockedNodeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnlockedNodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnlockedNodeModelCopyWith<UnlockedNodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnlockedNodeModelCopyWith<$Res> {
  factory $UnlockedNodeModelCopyWith(
    UnlockedNodeModel value,
    $Res Function(UnlockedNodeModel) then,
  ) = _$UnlockedNodeModelCopyWithImpl<$Res, UnlockedNodeModel>;
  @useResult
  $Res call({
    String id,
    String name,
    bool isUnlocked,
    bool isCleared,
    DateTime? unlockedAt,
  });
}

/// @nodoc
class _$UnlockedNodeModelCopyWithImpl<$Res, $Val extends UnlockedNodeModel>
    implements $UnlockedNodeModelCopyWith<$Res> {
  _$UnlockedNodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnlockedNodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isUnlocked = null,
    Object? isCleared = null,
    Object? unlockedAt = freezed,
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
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCleared: null == isCleared
                ? _value.isCleared
                : isCleared // ignore: cast_nullable_to_non_nullable
                      as bool,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnlockedNodeModelImplCopyWith<$Res>
    implements $UnlockedNodeModelCopyWith<$Res> {
  factory _$$UnlockedNodeModelImplCopyWith(
    _$UnlockedNodeModelImpl value,
    $Res Function(_$UnlockedNodeModelImpl) then,
  ) = __$$UnlockedNodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    bool isUnlocked,
    bool isCleared,
    DateTime? unlockedAt,
  });
}

/// @nodoc
class __$$UnlockedNodeModelImplCopyWithImpl<$Res>
    extends _$UnlockedNodeModelCopyWithImpl<$Res, _$UnlockedNodeModelImpl>
    implements _$$UnlockedNodeModelImplCopyWith<$Res> {
  __$$UnlockedNodeModelImplCopyWithImpl(
    _$UnlockedNodeModelImpl _value,
    $Res Function(_$UnlockedNodeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnlockedNodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isUnlocked = null,
    Object? isCleared = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(
      _$UnlockedNodeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCleared: null == isCleared
            ? _value.isCleared
            : isCleared // ignore: cast_nullable_to_non_nullable
                  as bool,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnlockedNodeModelImpl implements _UnlockedNodeModel {
  const _$UnlockedNodeModelImpl({
    required this.id,
    required this.name,
    required this.isUnlocked,
    required this.isCleared,
    this.unlockedAt,
  });

  factory _$UnlockedNodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnlockedNodeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final bool isUnlocked;
  @override
  final bool isCleared;
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'UnlockedNodeModel(id: $id, name: $name, isUnlocked: $isUnlocked, isCleared: $isCleared, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnlockedNodeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.isCleared, isCleared) ||
                other.isCleared == isCleared) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, isUnlocked, isCleared, unlockedAt);

  /// Create a copy of UnlockedNodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnlockedNodeModelImplCopyWith<_$UnlockedNodeModelImpl> get copyWith =>
      __$$UnlockedNodeModelImplCopyWithImpl<_$UnlockedNodeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UnlockedNodeModelImplToJson(this);
  }
}

abstract class _UnlockedNodeModel implements UnlockedNodeModel {
  const factory _UnlockedNodeModel({
    required final String id,
    required final String name,
    required final bool isUnlocked,
    required final bool isCleared,
    final DateTime? unlockedAt,
  }) = _$UnlockedNodeModelImpl;

  factory _UnlockedNodeModel.fromJson(Map<String, dynamic> json) =
      _$UnlockedNodeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get isUnlocked;
  @override
  bool get isCleared;
  @override
  DateTime? get unlockedAt;

  /// Create a copy of UnlockedNodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnlockedNodeModelImplCopyWith<_$UnlockedNodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegionUnlockResponseModel _$RegionUnlockResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _RegionUnlockResponseModel.fromJson(json);
}

/// @nodoc
mixin _$RegionUnlockResponseModel {
  UnlockedNodeModel? get region => throw _privateConstructorUsedError;
  int get fuelConsumed => throw _privateConstructorUsedError;
  int get currentFuel => throw _privateConstructorUsedError;
  bool get planetCleared => throw _privateConstructorUsedError;

  /// Serializes this RegionUnlockResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegionUnlockResponseModelCopyWith<RegionUnlockResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegionUnlockResponseModelCopyWith<$Res> {
  factory $RegionUnlockResponseModelCopyWith(
    RegionUnlockResponseModel value,
    $Res Function(RegionUnlockResponseModel) then,
  ) = _$RegionUnlockResponseModelCopyWithImpl<$Res, RegionUnlockResponseModel>;
  @useResult
  $Res call({
    UnlockedNodeModel? region,
    int fuelConsumed,
    int currentFuel,
    bool planetCleared,
  });

  $UnlockedNodeModelCopyWith<$Res>? get region;
}

/// @nodoc
class _$RegionUnlockResponseModelCopyWithImpl<
  $Res,
  $Val extends RegionUnlockResponseModel
>
    implements $RegionUnlockResponseModelCopyWith<$Res> {
  _$RegionUnlockResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? fuelConsumed = null,
    Object? currentFuel = null,
    Object? planetCleared = null,
  }) {
    return _then(
      _value.copyWith(
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as UnlockedNodeModel?,
            fuelConsumed: null == fuelConsumed
                ? _value.fuelConsumed
                : fuelConsumed // ignore: cast_nullable_to_non_nullable
                      as int,
            currentFuel: null == currentFuel
                ? _value.currentFuel
                : currentFuel // ignore: cast_nullable_to_non_nullable
                      as int,
            planetCleared: null == planetCleared
                ? _value.planetCleared
                : planetCleared // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnlockedNodeModelCopyWith<$Res>? get region {
    if (_value.region == null) {
      return null;
    }

    return $UnlockedNodeModelCopyWith<$Res>(_value.region!, (value) {
      return _then(_value.copyWith(region: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RegionUnlockResponseModelImplCopyWith<$Res>
    implements $RegionUnlockResponseModelCopyWith<$Res> {
  factory _$$RegionUnlockResponseModelImplCopyWith(
    _$RegionUnlockResponseModelImpl value,
    $Res Function(_$RegionUnlockResponseModelImpl) then,
  ) = __$$RegionUnlockResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UnlockedNodeModel? region,
    int fuelConsumed,
    int currentFuel,
    bool planetCleared,
  });

  @override
  $UnlockedNodeModelCopyWith<$Res>? get region;
}

/// @nodoc
class __$$RegionUnlockResponseModelImplCopyWithImpl<$Res>
    extends
        _$RegionUnlockResponseModelCopyWithImpl<
          $Res,
          _$RegionUnlockResponseModelImpl
        >
    implements _$$RegionUnlockResponseModelImplCopyWith<$Res> {
  __$$RegionUnlockResponseModelImplCopyWithImpl(
    _$RegionUnlockResponseModelImpl _value,
    $Res Function(_$RegionUnlockResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? fuelConsumed = null,
    Object? currentFuel = null,
    Object? planetCleared = null,
  }) {
    return _then(
      _$RegionUnlockResponseModelImpl(
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as UnlockedNodeModel?,
        fuelConsumed: null == fuelConsumed
            ? _value.fuelConsumed
            : fuelConsumed // ignore: cast_nullable_to_non_nullable
                  as int,
        currentFuel: null == currentFuel
            ? _value.currentFuel
            : currentFuel // ignore: cast_nullable_to_non_nullable
                  as int,
        planetCleared: null == planetCleared
            ? _value.planetCleared
            : planetCleared // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegionUnlockResponseModelImpl extends _RegionUnlockResponseModel {
  const _$RegionUnlockResponseModelImpl({
    this.region,
    required this.fuelConsumed,
    required this.currentFuel,
    required this.planetCleared,
  }) : super._();

  factory _$RegionUnlockResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegionUnlockResponseModelImplFromJson(json);

  @override
  final UnlockedNodeModel? region;
  @override
  final int fuelConsumed;
  @override
  final int currentFuel;
  @override
  final bool planetCleared;

  @override
  String toString() {
    return 'RegionUnlockResponseModel(region: $region, fuelConsumed: $fuelConsumed, currentFuel: $currentFuel, planetCleared: $planetCleared)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegionUnlockResponseModelImpl &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.fuelConsumed, fuelConsumed) ||
                other.fuelConsumed == fuelConsumed) &&
            (identical(other.currentFuel, currentFuel) ||
                other.currentFuel == currentFuel) &&
            (identical(other.planetCleared, planetCleared) ||
                other.planetCleared == planetCleared));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    region,
    fuelConsumed,
    currentFuel,
    planetCleared,
  );

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegionUnlockResponseModelImplCopyWith<_$RegionUnlockResponseModelImpl>
  get copyWith =>
      __$$RegionUnlockResponseModelImplCopyWithImpl<
        _$RegionUnlockResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegionUnlockResponseModelImplToJson(this);
  }
}

abstract class _RegionUnlockResponseModel extends RegionUnlockResponseModel {
  const factory _RegionUnlockResponseModel({
    final UnlockedNodeModel? region,
    required final int fuelConsumed,
    required final int currentFuel,
    required final bool planetCleared,
  }) = _$RegionUnlockResponseModelImpl;
  const _RegionUnlockResponseModel._() : super._();

  factory _RegionUnlockResponseModel.fromJson(Map<String, dynamic> json) =
      _$RegionUnlockResponseModelImpl.fromJson;

  @override
  UnlockedNodeModel? get region;
  @override
  int get fuelConsumed;
  @override
  int get currentFuel;
  @override
  bool get planetCleared;

  /// Create a copy of RegionUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegionUnlockResponseModelImplCopyWith<_$RegionUnlockResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PlanetUnlockResponseModel _$PlanetUnlockResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _PlanetUnlockResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PlanetUnlockResponseModel {
  UnlockedNodeModel? get planet => throw _privateConstructorUsedError;
  int get fuelConsumed => throw _privateConstructorUsedError;
  int get currentFuel => throw _privateConstructorUsedError;

  /// Serializes this PlanetUnlockResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanetUnlockResponseModelCopyWith<PlanetUnlockResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanetUnlockResponseModelCopyWith<$Res> {
  factory $PlanetUnlockResponseModelCopyWith(
    PlanetUnlockResponseModel value,
    $Res Function(PlanetUnlockResponseModel) then,
  ) = _$PlanetUnlockResponseModelCopyWithImpl<$Res, PlanetUnlockResponseModel>;
  @useResult
  $Res call({UnlockedNodeModel? planet, int fuelConsumed, int currentFuel});

  $UnlockedNodeModelCopyWith<$Res>? get planet;
}

/// @nodoc
class _$PlanetUnlockResponseModelCopyWithImpl<
  $Res,
  $Val extends PlanetUnlockResponseModel
>
    implements $PlanetUnlockResponseModelCopyWith<$Res> {
  _$PlanetUnlockResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planet = freezed,
    Object? fuelConsumed = null,
    Object? currentFuel = null,
  }) {
    return _then(
      _value.copyWith(
            planet: freezed == planet
                ? _value.planet
                : planet // ignore: cast_nullable_to_non_nullable
                      as UnlockedNodeModel?,
            fuelConsumed: null == fuelConsumed
                ? _value.fuelConsumed
                : fuelConsumed // ignore: cast_nullable_to_non_nullable
                      as int,
            currentFuel: null == currentFuel
                ? _value.currentFuel
                : currentFuel // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UnlockedNodeModelCopyWith<$Res>? get planet {
    if (_value.planet == null) {
      return null;
    }

    return $UnlockedNodeModelCopyWith<$Res>(_value.planet!, (value) {
      return _then(_value.copyWith(planet: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlanetUnlockResponseModelImplCopyWith<$Res>
    implements $PlanetUnlockResponseModelCopyWith<$Res> {
  factory _$$PlanetUnlockResponseModelImplCopyWith(
    _$PlanetUnlockResponseModelImpl value,
    $Res Function(_$PlanetUnlockResponseModelImpl) then,
  ) = __$$PlanetUnlockResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UnlockedNodeModel? planet, int fuelConsumed, int currentFuel});

  @override
  $UnlockedNodeModelCopyWith<$Res>? get planet;
}

/// @nodoc
class __$$PlanetUnlockResponseModelImplCopyWithImpl<$Res>
    extends
        _$PlanetUnlockResponseModelCopyWithImpl<
          $Res,
          _$PlanetUnlockResponseModelImpl
        >
    implements _$$PlanetUnlockResponseModelImplCopyWith<$Res> {
  __$$PlanetUnlockResponseModelImplCopyWithImpl(
    _$PlanetUnlockResponseModelImpl _value,
    $Res Function(_$PlanetUnlockResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planet = freezed,
    Object? fuelConsumed = null,
    Object? currentFuel = null,
  }) {
    return _then(
      _$PlanetUnlockResponseModelImpl(
        planet: freezed == planet
            ? _value.planet
            : planet // ignore: cast_nullable_to_non_nullable
                  as UnlockedNodeModel?,
        fuelConsumed: null == fuelConsumed
            ? _value.fuelConsumed
            : fuelConsumed // ignore: cast_nullable_to_non_nullable
                  as int,
        currentFuel: null == currentFuel
            ? _value.currentFuel
            : currentFuel // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanetUnlockResponseModelImpl extends _PlanetUnlockResponseModel {
  const _$PlanetUnlockResponseModelImpl({
    this.planet,
    required this.fuelConsumed,
    required this.currentFuel,
  }) : super._();

  factory _$PlanetUnlockResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanetUnlockResponseModelImplFromJson(json);

  @override
  final UnlockedNodeModel? planet;
  @override
  final int fuelConsumed;
  @override
  final int currentFuel;

  @override
  String toString() {
    return 'PlanetUnlockResponseModel(planet: $planet, fuelConsumed: $fuelConsumed, currentFuel: $currentFuel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanetUnlockResponseModelImpl &&
            (identical(other.planet, planet) || other.planet == planet) &&
            (identical(other.fuelConsumed, fuelConsumed) ||
                other.fuelConsumed == fuelConsumed) &&
            (identical(other.currentFuel, currentFuel) ||
                other.currentFuel == currentFuel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, planet, fuelConsumed, currentFuel);

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanetUnlockResponseModelImplCopyWith<_$PlanetUnlockResponseModelImpl>
  get copyWith =>
      __$$PlanetUnlockResponseModelImplCopyWithImpl<
        _$PlanetUnlockResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanetUnlockResponseModelImplToJson(this);
  }
}

abstract class _PlanetUnlockResponseModel extends PlanetUnlockResponseModel {
  const factory _PlanetUnlockResponseModel({
    final UnlockedNodeModel? planet,
    required final int fuelConsumed,
    required final int currentFuel,
  }) = _$PlanetUnlockResponseModelImpl;
  const _PlanetUnlockResponseModel._() : super._();

  factory _PlanetUnlockResponseModel.fromJson(Map<String, dynamic> json) =
      _$PlanetUnlockResponseModelImpl.fromJson;

  @override
  UnlockedNodeModel? get planet;
  @override
  int get fuelConsumed;
  @override
  int get currentFuel;

  /// Create a copy of PlanetUnlockResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanetUnlockResponseModelImplCopyWith<_$PlanetUnlockResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
