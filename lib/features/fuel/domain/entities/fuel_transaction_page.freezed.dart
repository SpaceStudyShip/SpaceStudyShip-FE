// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FuelTransactionPage {
  List<FuelTransactionEntity> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionPageCopyWith<FuelTransactionPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionPageCopyWith<$Res> {
  factory $FuelTransactionPageCopyWith(
    FuelTransactionPage value,
    $Res Function(FuelTransactionPage) then,
  ) = _$FuelTransactionPageCopyWithImpl<$Res, FuelTransactionPage>;
  @useResult
  $Res call({
    List<FuelTransactionEntity> items,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class _$FuelTransactionPageCopyWithImpl<$Res, $Val extends FuelTransactionPage>
    implements $FuelTransactionPageCopyWith<$Res> {
  _$FuelTransactionPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<FuelTransactionEntity>,
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
abstract class _$$FuelTransactionPageImplCopyWith<$Res>
    implements $FuelTransactionPageCopyWith<$Res> {
  factory _$$FuelTransactionPageImplCopyWith(
    _$FuelTransactionPageImpl value,
    $Res Function(_$FuelTransactionPageImpl) then,
  ) = __$$FuelTransactionPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FuelTransactionEntity> items,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class __$$FuelTransactionPageImplCopyWithImpl<$Res>
    extends _$FuelTransactionPageCopyWithImpl<$Res, _$FuelTransactionPageImpl>
    implements _$$FuelTransactionPageImplCopyWith<$Res> {
  __$$FuelTransactionPageImplCopyWithImpl(
    _$FuelTransactionPageImpl _value,
    $Res Function(_$FuelTransactionPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$FuelTransactionPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<FuelTransactionEntity>,
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

class _$FuelTransactionPageImpl extends _FuelTransactionPage {
  const _$FuelTransactionPageImpl({
    required final List<FuelTransactionEntity> items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  }) : _items = items,
       super._();

  final List<FuelTransactionEntity> _items;
  @override
  List<FuelTransactionEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
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
    return 'FuelTransactionPage(items: $items, page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    size,
    totalElements,
    totalPages,
  );

  /// Create a copy of FuelTransactionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionPageImplCopyWith<_$FuelTransactionPageImpl> get copyWith =>
      __$$FuelTransactionPageImplCopyWithImpl<_$FuelTransactionPageImpl>(
        this,
        _$identity,
      );
}

abstract class _FuelTransactionPage extends FuelTransactionPage {
  const factory _FuelTransactionPage({
    required final List<FuelTransactionEntity> items,
    required final int page,
    required final int size,
    required final int totalElements,
    required final int totalPages,
  }) = _$FuelTransactionPageImpl;
  const _FuelTransactionPage._() : super._();

  @override
  List<FuelTransactionEntity> get items;
  @override
  int get page;
  @override
  int get size;
  @override
  int get totalElements;
  @override
  int get totalPages;

  /// Create a copy of FuelTransactionPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionPageImplCopyWith<_$FuelTransactionPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
