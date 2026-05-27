// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayStatsNotifierHash() =>
    r'fc66cbacb28f5be7cfe7947a9a6499f882c80921';

/// 오늘 공부 통계 provider.
/// 인증 모드: 서버 GET /api/timer-sessions/today-stats 결과 신뢰.
/// 게스트 모드: 로컬 세션 리스트로 클라이언트 계산.
///
/// Copied from [TodayStatsNotifier].
@ProviderFor(TodayStatsNotifier)
final todayStatsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TodayStatsNotifier, TodayStats>.internal(
      TodayStatsNotifier.new,
      name: r'todayStatsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayStatsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodayStatsNotifier = AutoDisposeAsyncNotifier<TodayStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
