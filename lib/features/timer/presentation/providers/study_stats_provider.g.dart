// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayStudyMinutesHash() => r'945b739e7bb40dbb04d6d397d4cecb7a2664bf79';

/// 오늘 공부 시간 (분)
///
/// Copied from [todayStudyMinutes].
@ProviderFor(todayStudyMinutes)
final todayStudyMinutesProvider = AutoDisposeProvider<int>.internal(
  todayStudyMinutes,
  name: r'todayStudyMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayStudyMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayStudyMinutesRef = AutoDisposeProviderRef<int>;
String _$weeklyStudyMinutesHash() =>
    r'f972b83f62e0641552e1fe32d5d04482e9f55074';

/// 이번 주 공부 시간 (분) — 최근 7일
///
/// Copied from [weeklyStudyMinutes].
@ProviderFor(weeklyStudyMinutes)
final weeklyStudyMinutesProvider = AutoDisposeProvider<int>.internal(
  weeklyStudyMinutes,
  name: r'weeklyStudyMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyStudyMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyStudyMinutesRef = AutoDisposeProviderRef<int>;
String _$monthlyStudyMinutesHash() =>
    r'46281f77813a3b09026ab3aa09dbc3733e907a72';

/// 이번 달 공부 시간 (분) — todayStats 위임
///
/// Copied from [monthlyStudyMinutes].
@ProviderFor(monthlyStudyMinutes)
final monthlyStudyMinutesProvider = AutoDisposeProvider<int>.internal(
  monthlyStudyMinutes,
  name: r'monthlyStudyMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyStudyMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyStudyMinutesRef = AutoDisposeProviderRef<int>;
String _$totalStudyMinutesHash() => r'bd91b30decff70dbb57e5649252cff18b02607b9';

/// 전체 총 공부 시간 (분) — todayStats 위임
///
/// Copied from [totalStudyMinutes].
@ProviderFor(totalStudyMinutes)
final totalStudyMinutesProvider = AutoDisposeProvider<int>.internal(
  totalStudyMinutes,
  name: r'totalStudyMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalStudyMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalStudyMinutesRef = AutoDisposeProviderRef<int>;
String _$totalSessionCountHash() => r'76529512582e8e028fb000f1a4791f4095cb80a7';

/// 전체 세션 수 — todayStats 위임
///
/// Copied from [totalSessionCount].
@ProviderFor(totalSessionCount)
final totalSessionCountProvider = AutoDisposeProvider<int>.internal(
  totalSessionCount,
  name: r'totalSessionCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalSessionCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalSessionCountRef = AutoDisposeProviderRef<int>;
String _$currentStreakHash() => r'695c3e5cc1b3eef210917de2240ab38f7a862007';

/// 연속 공부 일수 (streak)
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreakRef = AutoDisposeProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
