// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerSessionFilter {
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get todoId => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionFilterCopyWith<TimerSessionFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionFilterCopyWith<$Res> {
  factory $TimerSessionFilterCopyWith(
    TimerSessionFilter value,
    $Res Function(TimerSessionFilter) then,
  ) = _$TimerSessionFilterCopyWithImpl<$Res, TimerSessionFilter>;
  @useResult
  $Res call({
    DateTime? startDate,
    DateTime? endDate,
    String? todoId,
    int page,
    int size,
  });
}

/// @nodoc
class _$TimerSessionFilterCopyWithImpl<$Res, $Val extends TimerSessionFilter>
    implements $TimerSessionFilterCopyWith<$Res> {
  _$TimerSessionFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? todoId = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _value.copyWith(
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            todoId: freezed == todoId
                ? _value.todoId
                : todoId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$TimerSessionFilterImplCopyWith<$Res>
    implements $TimerSessionFilterCopyWith<$Res> {
  factory _$$TimerSessionFilterImplCopyWith(
    _$TimerSessionFilterImpl value,
    $Res Function(_$TimerSessionFilterImpl) then,
  ) = __$$TimerSessionFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime? startDate,
    DateTime? endDate,
    String? todoId,
    int page,
    int size,
  });
}

/// @nodoc
class __$$TimerSessionFilterImplCopyWithImpl<$Res>
    extends _$TimerSessionFilterCopyWithImpl<$Res, _$TimerSessionFilterImpl>
    implements _$$TimerSessionFilterImplCopyWith<$Res> {
  __$$TimerSessionFilterImplCopyWithImpl(
    _$TimerSessionFilterImpl _value,
    $Res Function(_$TimerSessionFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? todoId = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _$TimerSessionFilterImpl(
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        todoId: freezed == todoId
            ? _value.todoId
            : todoId // ignore: cast_nullable_to_non_nullable
                  as String?,
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

class _$TimerSessionFilterImpl implements _TimerSessionFilter {
  const _$TimerSessionFilterImpl({
    this.startDate,
    this.endDate,
    this.todoId,
    this.page = 0,
    this.size = 20,
  });

  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String? todoId;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;

  @override
  String toString() {
    return 'TimerSessionFilter(startDate: $startDate, endDate: $endDate, todoId: $todoId, page: $page, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionFilterImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.todoId, todoId) || other.todoId == todoId) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, startDate, endDate, todoId, page, size);

  /// Create a copy of TimerSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionFilterImplCopyWith<_$TimerSessionFilterImpl> get copyWith =>
      __$$TimerSessionFilterImplCopyWithImpl<_$TimerSessionFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _TimerSessionFilter implements TimerSessionFilter {
  const factory _TimerSessionFilter({
    final DateTime? startDate,
    final DateTime? endDate,
    final String? todoId,
    final int page,
    final int size,
  }) = _$TimerSessionFilterImpl;

  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get todoId;
  @override
  int get page;
  @override
  int get size;

  /// Create a copy of TimerSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionFilterImplCopyWith<_$TimerSessionFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
