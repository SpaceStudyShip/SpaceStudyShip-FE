// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_page_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FuelTransactionPageResponseModel _$FuelTransactionPageResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _FuelTransactionPageResponseModel.fromJson(json);
}

/// @nodoc
mixin _$FuelTransactionPageResponseModel {
  List<FuelTransactionResponseModel> get content =>
      throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this FuelTransactionPageResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionPageResponseModelCopyWith<FuelTransactionPageResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionPageResponseModelCopyWith<$Res> {
  factory $FuelTransactionPageResponseModelCopyWith(
    FuelTransactionPageResponseModel value,
    $Res Function(FuelTransactionPageResponseModel) then,
  ) =
      _$FuelTransactionPageResponseModelCopyWithImpl<
        $Res,
        FuelTransactionPageResponseModel
      >;
  @useResult
  $Res call({
    List<FuelTransactionResponseModel> content,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class _$FuelTransactionPageResponseModelCopyWithImpl<
  $Res,
  $Val extends FuelTransactionPageResponseModel
>
    implements $FuelTransactionPageResponseModelCopyWith<$Res> {
  _$FuelTransactionPageResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<FuelTransactionResponseModel>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            totalElements: null == totalElements
                ? _value.totalElements
                : totalElements // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FuelTransactionPageResponseModelImplCopyWith<$Res>
    implements $FuelTransactionPageResponseModelCopyWith<$Res> {
  factory _$$FuelTransactionPageResponseModelImplCopyWith(
    _$FuelTransactionPageResponseModelImpl value,
    $Res Function(_$FuelTransactionPageResponseModelImpl) then,
  ) = __$$FuelTransactionPageResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FuelTransactionResponseModel> content,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class __$$FuelTransactionPageResponseModelImplCopyWithImpl<$Res>
    extends
        _$FuelTransactionPageResponseModelCopyWithImpl<
          $Res,
          _$FuelTransactionPageResponseModelImpl
        >
    implements _$$FuelTransactionPageResponseModelImplCopyWith<$Res> {
  __$$FuelTransactionPageResponseModelImplCopyWithImpl(
    _$FuelTransactionPageResponseModelImpl _value,
    $Res Function(_$FuelTransactionPageResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$FuelTransactionPageResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<FuelTransactionResponseModel>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        totalElements: null == totalElements
            ? _value.totalElements
            : totalElements // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FuelTransactionPageResponseModelImpl
    extends _FuelTransactionPageResponseModel {
  const _$FuelTransactionPageResponseModelImpl({
    required final List<FuelTransactionResponseModel> content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  }) : _content = content,
       super._();

  factory _$FuelTransactionPageResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$FuelTransactionPageResponseModelImplFromJson(json);

  final List<FuelTransactionResponseModel> _content;
  @override
  List<FuelTransactionResponseModel> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final int page;
  @override
  final int size;
  @override
  final int totalElements;
  @override
  final int totalPages;

  @override
  String toString() {
    return 'FuelTransactionPageResponseModel(content: $content, page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionPageResponseModelImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    page,
    size,
    totalElements,
    totalPages,
  );

  /// Create a copy of FuelTransactionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionPageResponseModelImplCopyWith<
    _$FuelTransactionPageResponseModelImpl
  >
  get copyWith =>
      __$$FuelTransactionPageResponseModelImplCopyWithImpl<
        _$FuelTransactionPageResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelTransactionPageResponseModelImplToJson(this);
  }
}

abstract class _FuelTransactionPageResponseModel
    extends FuelTransactionPageResponseModel {
  const factory _FuelTransactionPageResponseModel({
    required final List<FuelTransactionResponseModel> content,
    required final int page,
    required final int size,
    required final int totalElements,
    required final int totalPages,
  }) = _$FuelTransactionPageResponseModelImpl;
  const _FuelTransactionPageResponseModel._() : super._();

  factory _FuelTransactionPageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) = _$FuelTransactionPageResponseModelImpl.fromJson;

  @override
  List<FuelTransactionResponseModel> get content;
  @override
  int get page;
  @override
  int get size;
  @override
  int get totalElements;
  @override
  int get totalPages;

  /// Create a copy of FuelTransactionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionPageResponseModelImplCopyWith<
    _$FuelTransactionPageResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
