// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_page_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimerSessionPageResponseModel _$TimerSessionPageResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _TimerSessionPageResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TimerSessionPageResponseModel {
  List<TimerSessionResponseModel> get content =>
      throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this TimerSessionPageResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionPageResponseModelCopyWith<TimerSessionPageResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionPageResponseModelCopyWith<$Res> {
  factory $TimerSessionPageResponseModelCopyWith(
    TimerSessionPageResponseModel value,
    $Res Function(TimerSessionPageResponseModel) then,
  ) =
      _$TimerSessionPageResponseModelCopyWithImpl<
        $Res,
        TimerSessionPageResponseModel
      >;
  @useResult
  $Res call({
    List<TimerSessionResponseModel> content,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class _$TimerSessionPageResponseModelCopyWithImpl<
  $Res,
  $Val extends TimerSessionPageResponseModel
>
    implements $TimerSessionPageResponseModelCopyWith<$Res> {
  _$TimerSessionPageResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionPageResponseModel
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
                      as List<TimerSessionResponseModel>,
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
abstract class _$$TimerSessionPageResponseModelImplCopyWith<$Res>
    implements $TimerSessionPageResponseModelCopyWith<$Res> {
  factory _$$TimerSessionPageResponseModelImplCopyWith(
    _$TimerSessionPageResponseModelImpl value,
    $Res Function(_$TimerSessionPageResponseModelImpl) then,
  ) = __$$TimerSessionPageResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TimerSessionResponseModel> content,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class __$$TimerSessionPageResponseModelImplCopyWithImpl<$Res>
    extends
        _$TimerSessionPageResponseModelCopyWithImpl<
          $Res,
          _$TimerSessionPageResponseModelImpl
        >
    implements _$$TimerSessionPageResponseModelImplCopyWith<$Res> {
  __$$TimerSessionPageResponseModelImplCopyWithImpl(
    _$TimerSessionPageResponseModelImpl _value,
    $Res Function(_$TimerSessionPageResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionPageResponseModel
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
      _$TimerSessionPageResponseModelImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<TimerSessionResponseModel>,
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
class _$TimerSessionPageResponseModelImpl
    extends _TimerSessionPageResponseModel {
  const _$TimerSessionPageResponseModelImpl({
    required final List<TimerSessionResponseModel> content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  }) : _content = content,
       super._();

  factory _$TimerSessionPageResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TimerSessionPageResponseModelImplFromJson(json);

  final List<TimerSessionResponseModel> _content;
  @override
  List<TimerSessionResponseModel> get content {
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
    return 'TimerSessionPageResponseModel(content: $content, page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionPageResponseModelImpl &&
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

  /// Create a copy of TimerSessionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionPageResponseModelImplCopyWith<
    _$TimerSessionPageResponseModelImpl
  >
  get copyWith =>
      __$$TimerSessionPageResponseModelImplCopyWithImpl<
        _$TimerSessionPageResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerSessionPageResponseModelImplToJson(this);
  }
}

abstract class _TimerSessionPageResponseModel
    extends TimerSessionPageResponseModel {
  const factory _TimerSessionPageResponseModel({
    required final List<TimerSessionResponseModel> content,
    required final int page,
    required final int size,
    required final int totalElements,
    required final int totalPages,
  }) = _$TimerSessionPageResponseModelImpl;
  const _TimerSessionPageResponseModel._() : super._();

  factory _TimerSessionPageResponseModel.fromJson(Map<String, dynamic> json) =
      _$TimerSessionPageResponseModelImpl.fromJson;

  @override
  List<TimerSessionResponseModel> get content;
  @override
  int get page;
  @override
  int get size;
  @override
  int get totalElements;
  @override
  int get totalPages;

  /// Create a copy of TimerSessionPageResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionPageResponseModelImplCopyWith<
    _$TimerSessionPageResponseModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
