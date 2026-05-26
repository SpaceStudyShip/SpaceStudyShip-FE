// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodayStats {
  int get totalMinutes => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get lifetimeMinutes => throw _privateConstructorUsedError;
  int get lifetimeSessionCount => throw _privateConstructorUsedError;
  int get monthlyMinutes => throw _privateConstructorUsedError;

  /// Create a copy of TodayStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodayStatsCopyWith<TodayStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayStatsCopyWith<$Res> {
  factory $TodayStatsCopyWith(
    TodayStats value,
    $Res Function(TodayStats) then,
  ) = _$TodayStatsCopyWithImpl<$Res, TodayStats>;
  @useResult
  $Res call({
    int totalMinutes,
    int sessionCount,
    int streak,
    int lifetimeMinutes,
    int lifetimeSessionCount,
    int monthlyMinutes,
  });
}

/// @nodoc
class _$TodayStatsCopyWithImpl<$Res, $Val extends TodayStats>
    implements $TodayStatsCopyWith<$Res> {
  _$TodayStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodayStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalMinutes = null,
    Object? sessionCount = null,
    Object? streak = null,
    Object? lifetimeMinutes = null,
    Object? lifetimeSessionCount = null,
    Object? monthlyMinutes = null,
  }) {
    return _then(
      _value.copyWith(
            totalMinutes: null == totalMinutes
                ? _value.totalMinutes
                : totalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionCount: null == sessionCount
                ? _value.sessionCount
                : sessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            lifetimeMinutes: null == lifetimeMinutes
                ? _value.lifetimeMinutes
                : lifetimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            lifetimeSessionCount: null == lifetimeSessionCount
                ? _value.lifetimeSessionCount
                : lifetimeSessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyMinutes: null == monthlyMinutes
                ? _value.monthlyMinutes
                : monthlyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodayStatsImplCopyWith<$Res>
    implements $TodayStatsCopyWith<$Res> {
  factory _$$TodayStatsImplCopyWith(
    _$TodayStatsImpl value,
    $Res Function(_$TodayStatsImpl) then,
  ) = __$$TodayStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalMinutes,
    int sessionCount,
    int streak,
    int lifetimeMinutes,
    int lifetimeSessionCount,
    int monthlyMinutes,
  });
}

/// @nodoc
class __$$TodayStatsImplCopyWithImpl<$Res>
    extends _$TodayStatsCopyWithImpl<$Res, _$TodayStatsImpl>
    implements _$$TodayStatsImplCopyWith<$Res> {
  __$$TodayStatsImplCopyWithImpl(
    _$TodayStatsImpl _value,
    $Res Function(_$TodayStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodayStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalMinutes = null,
    Object? sessionCount = null,
    Object? streak = null,
    Object? lifetimeMinutes = null,
    Object? lifetimeSessionCount = null,
    Object? monthlyMinutes = null,
  }) {
    return _then(
      _$TodayStatsImpl(
        totalMinutes: null == totalMinutes
            ? _value.totalMinutes
            : totalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionCount: null == sessionCount
            ? _value.sessionCount
            : sessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        lifetimeMinutes: null == lifetimeMinutes
            ? _value.lifetimeMinutes
            : lifetimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        lifetimeSessionCount: null == lifetimeSessionCount
            ? _value.lifetimeSessionCount
            : lifetimeSessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyMinutes: null == monthlyMinutes
            ? _value.monthlyMinutes
            : monthlyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TodayStatsImpl implements _TodayStats {
  const _$TodayStatsImpl({
    required this.totalMinutes,
    required this.sessionCount,
    required this.streak,
    required this.lifetimeMinutes,
    required this.lifetimeSessionCount,
    required this.monthlyMinutes,
  });

  @override
  final int totalMinutes;
  @override
  final int sessionCount;
  @override
  final int streak;
  @override
  final int lifetimeMinutes;
  @override
  final int lifetimeSessionCount;
  @override
  final int monthlyMinutes;

  @override
  String toString() {
    return 'TodayStats(totalMinutes: $totalMinutes, sessionCount: $sessionCount, streak: $streak, lifetimeMinutes: $lifetimeMinutes, lifetimeSessionCount: $lifetimeSessionCount, monthlyMinutes: $monthlyMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayStatsImpl &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.lifetimeMinutes, lifetimeMinutes) ||
                other.lifetimeMinutes == lifetimeMinutes) &&
            (identical(other.lifetimeSessionCount, lifetimeSessionCount) ||
                other.lifetimeSessionCount == lifetimeSessionCount) &&
            (identical(other.monthlyMinutes, monthlyMinutes) ||
                other.monthlyMinutes == monthlyMinutes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalMinutes,
    sessionCount,
    streak,
    lifetimeMinutes,
    lifetimeSessionCount,
    monthlyMinutes,
  );

  /// Create a copy of TodayStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayStatsImplCopyWith<_$TodayStatsImpl> get copyWith =>
      __$$TodayStatsImplCopyWithImpl<_$TodayStatsImpl>(this, _$identity);
}

abstract class _TodayStats implements TodayStats {
  const factory _TodayStats({
    required final int totalMinutes,
    required final int sessionCount,
    required final int streak,
    required final int lifetimeMinutes,
    required final int lifetimeSessionCount,
    required final int monthlyMinutes,
  }) = _$TodayStatsImpl;

  @override
  int get totalMinutes;
  @override
  int get sessionCount;
  @override
  int get streak;
  @override
  int get lifetimeMinutes;
  @override
  int get lifetimeSessionCount;
  @override
  int get monthlyMinutes;

  /// Create a copy of TodayStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodayStatsImplCopyWith<_$TodayStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
