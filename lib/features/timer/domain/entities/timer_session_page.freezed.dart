// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerSessionPage {
  List<TimerSessionEntity> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionPageCopyWith<TimerSessionPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionPageCopyWith<$Res> {
  factory $TimerSessionPageCopyWith(
    TimerSessionPage value,
    $Res Function(TimerSessionPage) then,
  ) = _$TimerSessionPageCopyWithImpl<$Res, TimerSessionPage>;
  @useResult
  $Res call({
    List<TimerSessionEntity> items,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class _$TimerSessionPageCopyWithImpl<$Res, $Val extends TimerSessionPage>
    implements $TimerSessionPageCopyWith<$Res> {
  _$TimerSessionPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionPage
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
                      as List<TimerSessionEntity>,
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
abstract class _$$TimerSessionPageImplCopyWith<$Res>
    implements $TimerSessionPageCopyWith<$Res> {
  factory _$$TimerSessionPageImplCopyWith(
    _$TimerSessionPageImpl value,
    $Res Function(_$TimerSessionPageImpl) then,
  ) = __$$TimerSessionPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TimerSessionEntity> items,
    int page,
    int size,
    int totalElements,
    int totalPages,
  });
}

/// @nodoc
class __$$TimerSessionPageImplCopyWithImpl<$Res>
    extends _$TimerSessionPageCopyWithImpl<$Res, _$TimerSessionPageImpl>
    implements _$$TimerSessionPageImplCopyWith<$Res> {
  __$$TimerSessionPageImplCopyWithImpl(
    _$TimerSessionPageImpl _value,
    $Res Function(_$TimerSessionPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSessionPage
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
      _$TimerSessionPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TimerSessionEntity>,
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

class _$TimerSessionPageImpl extends _TimerSessionPage {
  const _$TimerSessionPageImpl({
    required final List<TimerSessionEntity> items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  }) : _items = items,
       super._();

  final List<TimerSessionEntity> _items;
  @override
  List<TimerSessionEntity> get items {
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
    return 'TimerSessionPage(items: $items, page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionPageImpl &&
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

  /// Create a copy of TimerSessionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionPageImplCopyWith<_$TimerSessionPageImpl> get copyWith =>
      __$$TimerSessionPageImplCopyWithImpl<_$TimerSessionPageImpl>(
        this,
        _$identity,
      );
}

abstract class _TimerSessionPage extends TimerSessionPage {
  const factory _TimerSessionPage({
    required final List<TimerSessionEntity> items,
    required final int page,
    required final int size,
    required final int totalElements,
    required final int totalPages,
  }) = _$TimerSessionPageImpl;
  const _TimerSessionPage._() : super._();

  @override
  List<TimerSessionEntity> get items;
  @override
  int get page;
  @override
  int get size;
  @override
  int get totalElements;
  @override
  int get totalPages;

  /// Create a copy of TimerSessionPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionPageImplCopyWith<_$TimerSessionPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
