// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_create_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CategoryCreateRequestModel {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get iconId => throw _privateConstructorUsedError;
  double? get positionX => throw _privateConstructorUsedError;
  double? get positionY => throw _privateConstructorUsedError;

  /// Serializes this CategoryCreateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCreateRequestModelCopyWith<CategoryCreateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCreateRequestModelCopyWith<$Res> {
  factory $CategoryCreateRequestModelCopyWith(
    CategoryCreateRequestModel value,
    $Res Function(CategoryCreateRequestModel) then,
  ) =
      _$CategoryCreateRequestModelCopyWithImpl<
        $Res,
        CategoryCreateRequestModel
      >;
  @useResult
  $Res call({
    String? id,
    String name,
    String? iconId,
    double? positionX,
    double? positionY,
  });
}

/// @nodoc
class _$CategoryCreateRequestModelCopyWithImpl<
  $Res,
  $Val extends CategoryCreateRequestModel
>
    implements $CategoryCreateRequestModelCopyWith<$Res> {
  _$CategoryCreateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? iconId = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iconId: freezed == iconId
                ? _value.iconId
                : iconId // ignore: cast_nullable_to_non_nullable
                      as String?,
            positionX: freezed == positionX
                ? _value.positionX
                : positionX // ignore: cast_nullable_to_non_nullable
                      as double?,
            positionY: freezed == positionY
                ? _value.positionY
                : positionY // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryCreateRequestModelImplCopyWith<$Res>
    implements $CategoryCreateRequestModelCopyWith<$Res> {
  factory _$$CategoryCreateRequestModelImplCopyWith(
    _$CategoryCreateRequestModelImpl value,
    $Res Function(_$CategoryCreateRequestModelImpl) then,
  ) = __$$CategoryCreateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String name,
    String? iconId,
    double? positionX,
    double? positionY,
  });
}

/// @nodoc
class __$$CategoryCreateRequestModelImplCopyWithImpl<$Res>
    extends
        _$CategoryCreateRequestModelCopyWithImpl<
          $Res,
          _$CategoryCreateRequestModelImpl
        >
    implements _$$CategoryCreateRequestModelImplCopyWith<$Res> {
  __$$CategoryCreateRequestModelImplCopyWithImpl(
    _$CategoryCreateRequestModelImpl _value,
    $Res Function(_$CategoryCreateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? iconId = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
  }) {
    return _then(
      _$CategoryCreateRequestModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iconId: freezed == iconId
            ? _value.iconId
            : iconId // ignore: cast_nullable_to_non_nullable
                  as String?,
        positionX: freezed == positionX
            ? _value.positionX
            : positionX // ignore: cast_nullable_to_non_nullable
                  as double?,
        positionY: freezed == positionY
            ? _value.positionY
            : positionY // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$CategoryCreateRequestModelImpl implements _CategoryCreateRequestModel {
  const _$CategoryCreateRequestModelImpl({
    this.id,
    required this.name,
    this.iconId,
    this.positionX,
    this.positionY,
  });

  @override
  final String? id;
  @override
  final String name;
  @override
  final String? iconId;
  @override
  final double? positionX;
  @override
  final double? positionY;

  @override
  String toString() {
    return 'CategoryCreateRequestModel(id: $id, name: $name, iconId: $iconId, positionX: $positionX, positionY: $positionY)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryCreateRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconId, iconId) || other.iconId == iconId) &&
            (identical(other.positionX, positionX) ||
                other.positionX == positionX) &&
            (identical(other.positionY, positionY) ||
                other.positionY == positionY));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, iconId, positionX, positionY);

  /// Create a copy of CategoryCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryCreateRequestModelImplCopyWith<_$CategoryCreateRequestModelImpl>
  get copyWith =>
      __$$CategoryCreateRequestModelImplCopyWithImpl<
        _$CategoryCreateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryCreateRequestModelImplToJson(this);
  }
}

abstract class _CategoryCreateRequestModel
    implements CategoryCreateRequestModel {
  const factory _CategoryCreateRequestModel({
    final String? id,
    required final String name,
    final String? iconId,
    final double? positionX,
    final double? positionY,
  }) = _$CategoryCreateRequestModelImpl;

  @override
  String? get id;
  @override
  String get name;
  @override
  String? get iconId;
  @override
  double? get positionX;
  @override
  double? get positionY;

  /// Create a copy of CategoryCreateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryCreateRequestModelImplCopyWith<_$CategoryCreateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
