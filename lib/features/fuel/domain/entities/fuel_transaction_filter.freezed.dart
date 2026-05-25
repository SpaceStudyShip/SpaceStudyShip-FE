// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_transaction_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FuelTransactionFilter {
  FuelTransactionType? get type => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;

  /// Create a copy of FuelTransactionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelTransactionFilterCopyWith<FuelTransactionFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelTransactionFilterCopyWith<$Res> {
  factory $FuelTransactionFilterCopyWith(
    FuelTransactionFilter value,
    $Res Function(FuelTransactionFilter) then,
  ) = _$FuelTransactionFilterCopyWithImpl<$Res, FuelTransactionFilter>;
  @useResult
  $Res call({
    FuelTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page,
    int size,
  });
}

/// @nodoc
class _$FuelTransactionFilterCopyWithImpl<
  $Res,
  $Val extends FuelTransactionFilter
>
    implements $FuelTransactionFilterCopyWith<$Res> {
  _$FuelTransactionFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelTransactionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _value.copyWith(
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FuelTransactionType?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FuelTransactionFilterImplCopyWith<$Res>
    implements $FuelTransactionFilterCopyWith<$Res> {
  factory _$$FuelTransactionFilterImplCopyWith(
    _$FuelTransactionFilterImpl value,
    $Res Function(_$FuelTransactionFilterImpl) then,
  ) = __$$FuelTransactionFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    FuelTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page,
    int size,
  });
}

/// @nodoc
class __$$FuelTransactionFilterImplCopyWithImpl<$Res>
    extends
        _$FuelTransactionFilterCopyWithImpl<$Res, _$FuelTransactionFilterImpl>
    implements _$$FuelTransactionFilterImplCopyWith<$Res> {
  __$$FuelTransactionFilterImplCopyWithImpl(
    _$FuelTransactionFilterImpl _value,
    $Res Function(_$FuelTransactionFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FuelTransactionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _$FuelTransactionFilterImpl(
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FuelTransactionType?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$FuelTransactionFilterImpl implements _FuelTransactionFilter {
  const _$FuelTransactionFilterImpl({
    this.type,
    this.startDate,
    this.endDate,
    this.page = 0,
    this.size = 20,
  });

  @override
  final FuelTransactionType? type;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;

  @override
  String toString() {
    return 'FuelTransactionFilter(type: $type, startDate: $startDate, endDate: $endDate, page: $page, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelTransactionFilterImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, startDate, endDate, page, size);

  /// Create a copy of FuelTransactionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelTransactionFilterImplCopyWith<_$FuelTransactionFilterImpl>
  get copyWith =>
      __$$FuelTransactionFilterImplCopyWithImpl<_$FuelTransactionFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _FuelTransactionFilter implements FuelTransactionFilter {
  const factory _FuelTransactionFilter({
    final FuelTransactionType? type,
    final DateTime? startDate,
    final DateTime? endDate,
    final int page,
    final int size,
  }) = _$FuelTransactionFilterImpl;

  @override
  FuelTransactionType? get type;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  int get page;
  @override
  int get size;

  /// Create a copy of FuelTransactionFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelTransactionFilterImplCopyWith<_$FuelTransactionFilterImpl>
  get copyWith => throw _privateConstructorUsedError;
}
