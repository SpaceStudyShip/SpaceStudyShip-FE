// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planet_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlanetResponseModel _$PlanetResponseModelFromJson(Map<String, dynamic> json) {
  return _PlanetResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PlanetResponseModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nodeType => throw _privateConstructorUsedError;
  int get depth => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get prerequisiteId => throw _privateConstructorUsedError;
  int get requiredFuel => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  bool get isCleared => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get mapX => throw _privateConstructorUsedError;
  double get mapY => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;
  ProgressResponseModel? get progress => throw _privateConstructorUsedError;

  /// Serializes this PlanetResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanetResponseModelCopyWith<PlanetResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanetResponseModelCopyWith<$Res> {
  factory $PlanetResponseModelCopyWith(
    PlanetResponseModel value,
    $Res Function(PlanetResponseModel) then,
  ) = _$PlanetResponseModelCopyWithImpl<$Res, PlanetResponseModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String nodeType,
    int depth,
    String icon,
    String? parentId,
    String? prerequisiteId,
    int requiredFuel,
    bool isUnlocked,
    bool isCleared,
    int sortOrder,
    String description,
    double mapX,
    double mapY,
    DateTime? unlockedAt,
    ProgressResponseModel? progress,
  });

  $ProgressResponseModelCopyWith<$Res>? get progress;
}

/// @nodoc
class _$PlanetResponseModelCopyWithImpl<$Res, $Val extends PlanetResponseModel>
    implements $PlanetResponseModelCopyWith<$Res> {
  _$PlanetResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nodeType = null,
    Object? depth = null,
    Object? icon = null,
    Object? parentId = freezed,
    Object? prerequisiteId = freezed,
    Object? requiredFuel = null,
    Object? isUnlocked = null,
    Object? isCleared = null,
    Object? sortOrder = null,
    Object? description = null,
    Object? mapX = null,
    Object? mapY = null,
    Object? unlockedAt = freezed,
    Object? progress = freezed,
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
            nodeType: null == nodeType
                ? _value.nodeType
                : nodeType // ignore: cast_nullable_to_non_nullable
                      as String,
            depth: null == depth
                ? _value.depth
                : depth // ignore: cast_nullable_to_non_nullable
                      as int,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            prerequisiteId: freezed == prerequisiteId
                ? _value.prerequisiteId
                : prerequisiteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            requiredFuel: null == requiredFuel
                ? _value.requiredFuel
                : requiredFuel // ignore: cast_nullable_to_non_nullable
                      as int,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCleared: null == isCleared
                ? _value.isCleared
                : isCleared // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            mapX: null == mapX
                ? _value.mapX
                : mapX // ignore: cast_nullable_to_non_nullable
                      as double,
            mapY: null == mapY
                ? _value.mapY
                : mapY // ignore: cast_nullable_to_non_nullable
                      as double,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as ProgressResponseModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressResponseModelCopyWith<$Res>? get progress {
    if (_value.progress == null) {
      return null;
    }

    return $ProgressResponseModelCopyWith<$Res>(_value.progress!, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlanetResponseModelImplCopyWith<$Res>
    implements $PlanetResponseModelCopyWith<$Res> {
  factory _$$PlanetResponseModelImplCopyWith(
    _$PlanetResponseModelImpl value,
    $Res Function(_$PlanetResponseModelImpl) then,
  ) = __$$PlanetResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String nodeType,
    int depth,
    String icon,
    String? parentId,
    String? prerequisiteId,
    int requiredFuel,
    bool isUnlocked,
    bool isCleared,
    int sortOrder,
    String description,
    double mapX,
    double mapY,
    DateTime? unlockedAt,
    ProgressResponseModel? progress,
  });

  @override
  $ProgressResponseModelCopyWith<$Res>? get progress;
}

/// @nodoc
class __$$PlanetResponseModelImplCopyWithImpl<$Res>
    extends _$PlanetResponseModelCopyWithImpl<$Res, _$PlanetResponseModelImpl>
    implements _$$PlanetResponseModelImplCopyWith<$Res> {
  __$$PlanetResponseModelImplCopyWithImpl(
    _$PlanetResponseModelImpl _value,
    $Res Function(_$PlanetResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nodeType = null,
    Object? depth = null,
    Object? icon = null,
    Object? parentId = freezed,
    Object? prerequisiteId = freezed,
    Object? requiredFuel = null,
    Object? isUnlocked = null,
    Object? isCleared = null,
    Object? sortOrder = null,
    Object? description = null,
    Object? mapX = null,
    Object? mapY = null,
    Object? unlockedAt = freezed,
    Object? progress = freezed,
  }) {
    return _then(
      _$PlanetResponseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nodeType: null == nodeType
            ? _value.nodeType
            : nodeType // ignore: cast_nullable_to_non_nullable
                  as String,
        depth: null == depth
            ? _value.depth
            : depth // ignore: cast_nullable_to_non_nullable
                  as int,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        prerequisiteId: freezed == prerequisiteId
            ? _value.prerequisiteId
            : prerequisiteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        requiredFuel: null == requiredFuel
            ? _value.requiredFuel
            : requiredFuel // ignore: cast_nullable_to_non_nullable
                  as int,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCleared: null == isCleared
            ? _value.isCleared
            : isCleared // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        mapX: null == mapX
            ? _value.mapX
            : mapX // ignore: cast_nullable_to_non_nullable
                  as double,
        mapY: null == mapY
            ? _value.mapY
            : mapY // ignore: cast_nullable_to_non_nullable
                  as double,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as ProgressResponseModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanetResponseModelImpl extends _PlanetResponseModel {
  const _$PlanetResponseModelImpl({
    required this.id,
    required this.name,
    required this.nodeType,
    required this.depth,
    required this.icon,
    this.parentId,
    this.prerequisiteId,
    required this.requiredFuel,
    required this.isUnlocked,
    required this.isCleared,
    required this.sortOrder,
    this.description = '',
    this.mapX = 0.5,
    this.mapY = 0.0,
    this.unlockedAt,
    this.progress,
  }) : super._();

  factory _$PlanetResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanetResponseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String nodeType;
  @override
  final int depth;
  @override
  final String icon;
  @override
  final String? parentId;
  @override
  final String? prerequisiteId;
  @override
  final int requiredFuel;
  @override
  final bool isUnlocked;
  @override
  final bool isCleared;
  @override
  final int sortOrder;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final double mapX;
  @override
  @JsonKey()
  final double mapY;
  @override
  final DateTime? unlockedAt;
  @override
  final ProgressResponseModel? progress;

  @override
  String toString() {
    return 'PlanetResponseModel(id: $id, name: $name, nodeType: $nodeType, depth: $depth, icon: $icon, parentId: $parentId, prerequisiteId: $prerequisiteId, requiredFuel: $requiredFuel, isUnlocked: $isUnlocked, isCleared: $isCleared, sortOrder: $sortOrder, description: $description, mapX: $mapX, mapY: $mapY, unlockedAt: $unlockedAt, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanetResponseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nodeType, nodeType) ||
                other.nodeType == nodeType) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.prerequisiteId, prerequisiteId) ||
                other.prerequisiteId == prerequisiteId) &&
            (identical(other.requiredFuel, requiredFuel) ||
                other.requiredFuel == requiredFuel) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.isCleared, isCleared) ||
                other.isCleared == isCleared) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.mapX, mapX) || other.mapX == mapX) &&
            (identical(other.mapY, mapY) || other.mapY == mapY) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    nodeType,
    depth,
    icon,
    parentId,
    prerequisiteId,
    requiredFuel,
    isUnlocked,
    isCleared,
    sortOrder,
    description,
    mapX,
    mapY,
    unlockedAt,
    progress,
  );

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanetResponseModelImplCopyWith<_$PlanetResponseModelImpl> get copyWith =>
      __$$PlanetResponseModelImplCopyWithImpl<_$PlanetResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanetResponseModelImplToJson(this);
  }
}

abstract class _PlanetResponseModel extends PlanetResponseModel {
  const factory _PlanetResponseModel({
    required final String id,
    required final String name,
    required final String nodeType,
    required final int depth,
    required final String icon,
    final String? parentId,
    final String? prerequisiteId,
    required final int requiredFuel,
    required final bool isUnlocked,
    required final bool isCleared,
    required final int sortOrder,
    final String description,
    final double mapX,
    final double mapY,
    final DateTime? unlockedAt,
    final ProgressResponseModel? progress,
  }) = _$PlanetResponseModelImpl;
  const _PlanetResponseModel._() : super._();

  factory _PlanetResponseModel.fromJson(Map<String, dynamic> json) =
      _$PlanetResponseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get nodeType;
  @override
  int get depth;
  @override
  String get icon;
  @override
  String? get parentId;
  @override
  String? get prerequisiteId;
  @override
  int get requiredFuel;
  @override
  bool get isUnlocked;
  @override
  bool get isCleared;
  @override
  int get sortOrder;
  @override
  String get description;
  @override
  double get mapX;
  @override
  double get mapY;
  @override
  DateTime? get unlockedAt;
  @override
  ProgressResponseModel? get progress;

  /// Create a copy of PlanetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanetResponseModelImplCopyWith<_$PlanetResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressResponseModel _$ProgressResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _ProgressResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ProgressResponseModel {
  int get clearedChildren => throw _privateConstructorUsedError;
  int get totalChildren => throw _privateConstructorUsedError;
  double get progressRatio => throw _privateConstructorUsedError;

  /// Serializes this ProgressResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressResponseModelCopyWith<ProgressResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressResponseModelCopyWith<$Res> {
  factory $ProgressResponseModelCopyWith(
    ProgressResponseModel value,
    $Res Function(ProgressResponseModel) then,
  ) = _$ProgressResponseModelCopyWithImpl<$Res, ProgressResponseModel>;
  @useResult
  $Res call({int clearedChildren, int totalChildren, double progressRatio});
}

/// @nodoc
class _$ProgressResponseModelCopyWithImpl<
  $Res,
  $Val extends ProgressResponseModel
>
    implements $ProgressResponseModelCopyWith<$Res> {
  _$ProgressResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clearedChildren = null,
    Object? totalChildren = null,
    Object? progressRatio = null,
  }) {
    return _then(
      _value.copyWith(
            clearedChildren: null == clearedChildren
                ? _value.clearedChildren
                : clearedChildren // ignore: cast_nullable_to_non_nullable
                      as int,
            totalChildren: null == totalChildren
                ? _value.totalChildren
                : totalChildren // ignore: cast_nullable_to_non_nullable
                      as int,
            progressRatio: null == progressRatio
                ? _value.progressRatio
                : progressRatio // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressResponseModelImplCopyWith<$Res>
    implements $ProgressResponseModelCopyWith<$Res> {
  factory _$$ProgressResponseModelImplCopyWith(
    _$ProgressResponseModelImpl value,
    $Res Function(_$ProgressResponseModelImpl) then,
  ) = __$$ProgressResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int clearedChildren, int totalChildren, double progressRatio});
}

/// @nodoc
class __$$ProgressResponseModelImplCopyWithImpl<$Res>
    extends
        _$ProgressResponseModelCopyWithImpl<$Res, _$ProgressResponseModelImpl>
    implements _$$ProgressResponseModelImplCopyWith<$Res> {
  __$$ProgressResponseModelImplCopyWithImpl(
    _$ProgressResponseModelImpl _value,
    $Res Function(_$ProgressResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clearedChildren = null,
    Object? totalChildren = null,
    Object? progressRatio = null,
  }) {
    return _then(
      _$ProgressResponseModelImpl(
        clearedChildren: null == clearedChildren
            ? _value.clearedChildren
            : clearedChildren // ignore: cast_nullable_to_non_nullable
                  as int,
        totalChildren: null == totalChildren
            ? _value.totalChildren
            : totalChildren // ignore: cast_nullable_to_non_nullable
                  as int,
        progressRatio: null == progressRatio
            ? _value.progressRatio
            : progressRatio // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressResponseModelImpl implements _ProgressResponseModel {
  const _$ProgressResponseModelImpl({
    required this.clearedChildren,
    required this.totalChildren,
    this.progressRatio = 0.0,
  });

  factory _$ProgressResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressResponseModelImplFromJson(json);

  @override
  final int clearedChildren;
  @override
  final int totalChildren;
  @override
  @JsonKey()
  final double progressRatio;

  @override
  String toString() {
    return 'ProgressResponseModel(clearedChildren: $clearedChildren, totalChildren: $totalChildren, progressRatio: $progressRatio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressResponseModelImpl &&
            (identical(other.clearedChildren, clearedChildren) ||
                other.clearedChildren == clearedChildren) &&
            (identical(other.totalChildren, totalChildren) ||
                other.totalChildren == totalChildren) &&
            (identical(other.progressRatio, progressRatio) ||
                other.progressRatio == progressRatio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, clearedChildren, totalChildren, progressRatio);

  /// Create a copy of ProgressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressResponseModelImplCopyWith<_$ProgressResponseModelImpl>
  get copyWith =>
      __$$ProgressResponseModelImplCopyWithImpl<_$ProgressResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressResponseModelImplToJson(this);
  }
}

abstract class _ProgressResponseModel implements ProgressResponseModel {
  const factory _ProgressResponseModel({
    required final int clearedChildren,
    required final int totalChildren,
    final double progressRatio,
  }) = _$ProgressResponseModelImpl;

  factory _ProgressResponseModel.fromJson(Map<String, dynamic> json) =
      _$ProgressResponseModelImpl.fromJson;

  @override
  int get clearedChildren;
  @override
  int get totalChildren;
  @override
  double get progressRatio;

  /// Create a copy of ProgressResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressResponseModelImplCopyWith<_$ProgressResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
