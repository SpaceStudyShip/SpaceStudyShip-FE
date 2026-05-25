// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_update_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CategoryUpdateRequestModel {
  String? get name => throw _privateConstructorUsedError;
  String? get iconId => throw _privateConstructorUsedError;
  double? get positionX => throw _privateConstructorUsedError;
  double? get positionY => throw _privateConstructorUsedError;

  /// Serializes this CategoryUpdateRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryUpdateRequestModelCopyWith<CategoryUpdateRequestModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryUpdateRequestModelCopyWith<$Res> {
  factory $CategoryUpdateRequestModelCopyWith(
    CategoryUpdateRequestModel value,
    $Res Function(CategoryUpdateRequestModel) then,
  ) =
      _$CategoryUpdateRequestModelCopyWithImpl<
        $Res,
        CategoryUpdateRequestModel
      >;
  @useResult
  $Res call({
    String? name,
    String? iconId,
    double? positionX,
    double? positionY,
  });
}

/// @nodoc
class _$CategoryUpdateRequestModelCopyWithImpl<
  $Res,
  $Val extends CategoryUpdateRequestModel
>
    implements $CategoryUpdateRequestModelCopyWith<$Res> {
  _$CategoryUpdateRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? iconId = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$CategoryUpdateRequestModelImplCopyWith<$Res>
    implements $CategoryUpdateRequestModelCopyWith<$Res> {
  factory _$$CategoryUpdateRequestModelImplCopyWith(
    _$CategoryUpdateRequestModelImpl value,
    $Res Function(_$CategoryUpdateRequestModelImpl) then,
  ) = __$$CategoryUpdateRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? iconId,
    double? positionX,
    double? positionY,
  });
}

/// @nodoc
class __$$CategoryUpdateRequestModelImplCopyWithImpl<$Res>
    extends
        _$CategoryUpdateRequestModelCopyWithImpl<
          $Res,
          _$CategoryUpdateRequestModelImpl
        >
    implements _$$CategoryUpdateRequestModelImplCopyWith<$Res> {
  __$$CategoryUpdateRequestModelImplCopyWithImpl(
    _$CategoryUpdateRequestModelImpl _value,
    $Res Function(_$CategoryUpdateRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? iconId = freezed,
    Object? positionX = freezed,
    Object? positionY = freezed,
  }) {
    return _then(
      _$CategoryUpdateRequestModelImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$CategoryUpdateRequestModelImpl implements _CategoryUpdateRequestModel {
  const _$CategoryUpdateRequestModelImpl({
    this.name,
    this.iconId,
    this.positionX,
    this.positionY,
  });

  @override
  final String? name;
  @override
  final String? iconId;
  @override
  final double? positionX;
  @override
  final double? positionY;

  @override
  String toString() {
    return 'CategoryUpdateRequestModel(name: $name, iconId: $iconId, positionX: $positionX, positionY: $positionY)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryUpdateRequestModelImpl &&
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
      Object.hash(runtimeType, name, iconId, positionX, positionY);

  /// Create a copy of CategoryUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryUpdateRequestModelImplCopyWith<_$CategoryUpdateRequestModelImpl>
  get copyWith =>
      __$$CategoryUpdateRequestModelImplCopyWithImpl<
        _$CategoryUpdateRequestModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryUpdateRequestModelImplToJson(this);
  }
}

abstract class _CategoryUpdateRequestModel
    implements CategoryUpdateRequestModel {
  const factory _CategoryUpdateRequestModel({
    final String? name,
    final String? iconId,
    final double? positionX,
    final double? positionY,
  }) = _$CategoryUpdateRequestModelImpl;

  @override
  String? get name;
  @override
  String? get iconId;
  @override
  double? get positionX;
  @override
  double? get positionY;

  /// Create a copy of CategoryUpdateRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryUpdateRequestModelImplCopyWith<_$CategoryUpdateRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
