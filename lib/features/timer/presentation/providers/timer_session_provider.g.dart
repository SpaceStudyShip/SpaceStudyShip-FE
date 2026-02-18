// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerSessionLocalDataSourceHash() =>
    r'036f4f7bc4c9598e7d1ef9cfc7c7fd77290c4b7b';

/// See also [timerSessionLocalDataSource].
@ProviderFor(timerSessionLocalDataSource)
final timerSessionLocalDataSourceProvider =
    AutoDisposeProvider<TimerSessionLocalDataSource>.internal(
      timerSessionLocalDataSource,
      name: r'timerSessionLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timerSessionLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerSessionLocalDataSourceRef =
    AutoDisposeProviderRef<TimerSessionLocalDataSource>;
String _$timerSessionRepositoryHash() =>
    r'e2245e2083ff88ac8aea256b6fbac6d63d42d265';

/// See also [timerSessionRepository].
@ProviderFor(timerSessionRepository)
final timerSessionRepositoryProvider =
    AutoDisposeProvider<TimerSessionRepository>.internal(
      timerSessionRepository,
      name: r'timerSessionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timerSessionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerSessionRepositoryRef =
    AutoDisposeProviderRef<TimerSessionRepository>;
String _$sortedDateGroupsHash() => r'5eedfa42ea64c0ab6565cfdb85775086adf135f9';

/// 전체 세션을 날짜별로 그룹화 (최신순 정렬)
///
/// Copied from [sortedDateGroups].
@ProviderFor(sortedDateGroups)
final sortedDateGroupsProvider = AutoDisposeProvider<List<DateGroup>>.internal(
  sortedDateGroups,
  name: r'sortedDateGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sortedDateGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedDateGroupsRef = AutoDisposeProviderRef<List<DateGroup>>;
String _$timerSessionListNotifierHash() =>
    r'1a10d67f86e388c1979cedaff92fed6d55ecc7b7';

/// See also [TimerSessionListNotifier].
@ProviderFor(TimerSessionListNotifier)
final timerSessionListNotifierProvider =
    AutoDisposeNotifierProvider<
      TimerSessionListNotifier,
      List<TimerSessionEntity>
    >.internal(
      TimerSessionListNotifier.new,
      name: r'timerSessionListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timerSessionListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimerSessionListNotifier =
    AutoDisposeNotifier<List<TimerSessionEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
