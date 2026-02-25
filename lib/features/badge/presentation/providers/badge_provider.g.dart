// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badgeLocalDataSourceHash() =>
    r'd43699bf119fee0e75d67d3c818e1b6e2f06471f';

/// See also [badgeLocalDataSource].
@ProviderFor(badgeLocalDataSource)
final badgeLocalDataSourceProvider = Provider<BadgeLocalDataSource>.internal(
  badgeLocalDataSource,
  name: r'badgeLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$badgeLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BadgeLocalDataSourceRef = ProviderRef<BadgeLocalDataSource>;
String _$badgeRepositoryHash() => r'8ec3797da110361989e45b34ab110db942cd7819';

/// See also [badgeRepository].
@ProviderFor(badgeRepository)
final badgeRepositoryProvider = Provider<BadgeRepository>.internal(
  badgeRepository,
  name: r'badgeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$badgeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BadgeRepositoryRef = ProviderRef<BadgeRepository>;
String _$unlockedBadgeCountHash() =>
    r'59470c125de74ad9f7018631f68522439aba41c7';

/// 해금된 배지 수
///
/// Copied from [unlockedBadgeCount].
@ProviderFor(unlockedBadgeCount)
final unlockedBadgeCountProvider = AutoDisposeProvider<int>.internal(
  unlockedBadgeCount,
  name: r'unlockedBadgeCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedBadgeCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnlockedBadgeCountRef = AutoDisposeProviderRef<int>;
String _$totalBadgeCountHash() => r'8f883df1ac36590afb12805d1ac232ae371d2fa3';

/// 전체 배지 수
///
/// Copied from [totalBadgeCount].
@ProviderFor(totalBadgeCount)
final totalBadgeCountProvider = AutoDisposeProvider<int>.internal(
  totalBadgeCount,
  name: r'totalBadgeCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalBadgeCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalBadgeCountRef = AutoDisposeProviderRef<int>;
String _$hasNewBadgeHash() => r'47055e2a9fe5e65d47a791db44836b999977879c';

/// 신규(New) 배지 존재 여부
///
/// Copied from [hasNewBadge].
@ProviderFor(hasNewBadge)
final hasNewBadgeProvider = AutoDisposeProvider<bool>.internal(
  hasNewBadge,
  name: r'hasNewBadgeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasNewBadgeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasNewBadgeRef = AutoDisposeProviderRef<bool>;
String _$badgeNotifierHash() => r'ffb04febc13fe1c931090760cd1975901f11425d';

/// See also [BadgeNotifier].
@ProviderFor(BadgeNotifier)
final badgeNotifierProvider =
    NotifierProvider<BadgeNotifier, List<BadgeEntity>>.internal(
      BadgeNotifier.new,
      name: r'badgeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$badgeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BadgeNotifier = Notifier<List<BadgeEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
