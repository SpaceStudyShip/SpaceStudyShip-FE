// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerSessionLocalDataSourceHash() =>
    r'8bcc71fe1733c226bbd76443bf146612fc6fd813';

/// See also [timerSessionLocalDataSource].
@ProviderFor(timerSessionLocalDataSource)
final timerSessionLocalDataSourceProvider =
    Provider<TimerSessionLocalDataSource>.internal(
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
    ProviderRef<TimerSessionLocalDataSource>;
String _$timerSessionRemoteDataSourceHash() =>
    r'b28f8036453aa9e4afc4d2e2cac85b3676494996';

/// See also [timerSessionRemoteDataSource].
@ProviderFor(timerSessionRemoteDataSource)
final timerSessionRemoteDataSourceProvider =
    Provider<TimerSessionRemoteDataSource>.internal(
      timerSessionRemoteDataSource,
      name: r'timerSessionRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timerSessionRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerSessionRemoteDataSourceRef =
    ProviderRef<TimerSessionRemoteDataSource>;
String _$timerSessionRepositoryHash() =>
    r'5c0a1defa5d096fe118d68770b0ab05660249dd4';

/// See also [timerSessionRepository].
@ProviderFor(timerSessionRepository)
final timerSessionRepositoryProvider =
    Provider<TimerSessionRepository>.internal(
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
typedef TimerSessionRepositoryRef = ProviderRef<TimerSessionRepository>;
String _$timerSessionsPageHash() => r'3e4f81a2a34531295ea0d8dadf4f8ae2c0d2135e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [timerSessionsPage].
@ProviderFor(timerSessionsPage)
const timerSessionsPageProvider = TimerSessionsPageFamily();

/// See also [timerSessionsPage].
class TimerSessionsPageFamily extends Family<AsyncValue<TimerSessionPage>> {
  /// See also [timerSessionsPage].
  const TimerSessionsPageFamily();

  /// See also [timerSessionsPage].
  TimerSessionsPageProvider call(TimerSessionFilter filter) {
    return TimerSessionsPageProvider(filter);
  }

  @override
  TimerSessionsPageProvider getProviderOverride(
    covariant TimerSessionsPageProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timerSessionsPageProvider';
}

/// See also [timerSessionsPage].
class TimerSessionsPageProvider
    extends AutoDisposeFutureProvider<TimerSessionPage> {
  /// See also [timerSessionsPage].
  TimerSessionsPageProvider(TimerSessionFilter filter)
    : this._internal(
        (ref) => timerSessionsPage(ref as TimerSessionsPageRef, filter),
        from: timerSessionsPageProvider,
        name: r'timerSessionsPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timerSessionsPageHash,
        dependencies: TimerSessionsPageFamily._dependencies,
        allTransitiveDependencies:
            TimerSessionsPageFamily._allTransitiveDependencies,
        filter: filter,
      );

  TimerSessionsPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final TimerSessionFilter filter;

  @override
  Override overrideWith(
    FutureOr<TimerSessionPage> Function(TimerSessionsPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimerSessionsPageProvider._internal(
        (ref) => create(ref as TimerSessionsPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimerSessionPage> createElement() {
    return _TimerSessionsPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimerSessionsPageProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimerSessionsPageRef on AutoDisposeFutureProviderRef<TimerSessionPage> {
  /// The parameter `filter` of this provider.
  TimerSessionFilter get filter;
}

class _TimerSessionsPageProviderElement
    extends AutoDisposeFutureProviderElement<TimerSessionPage>
    with TimerSessionsPageRef {
  _TimerSessionsPageProviderElement(super.provider);

  @override
  TimerSessionFilter get filter => (origin as TimerSessionsPageProvider).filter;
}

String _$timerHistoryPageHash() => r'c2c2e6f65aeb20a155c582dfc0b81dff0330577a';

/// 기록 화면용 페이지 조회.
/// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
/// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
///
/// Copied from [timerHistoryPage].
@ProviderFor(timerHistoryPage)
const timerHistoryPageProvider = TimerHistoryPageFamily();

/// 기록 화면용 페이지 조회.
/// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
/// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
///
/// Copied from [timerHistoryPage].
class TimerHistoryPageFamily extends Family<AsyncValue<TimerSessionPage>> {
  /// 기록 화면용 페이지 조회.
  /// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
  /// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
  ///
  /// Copied from [timerHistoryPage].
  const TimerHistoryPageFamily();

  /// 기록 화면용 페이지 조회.
  /// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
  /// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
  ///
  /// Copied from [timerHistoryPage].
  TimerHistoryPageProvider call(int page) {
    return TimerHistoryPageProvider(page);
  }

  @override
  TimerHistoryPageProvider getProviderOverride(
    covariant TimerHistoryPageProvider provider,
  ) {
    return call(provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timerHistoryPageProvider';
}

/// 기록 화면용 페이지 조회.
/// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
/// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
///
/// Copied from [timerHistoryPage].
class TimerHistoryPageProvider
    extends AutoDisposeFutureProvider<TimerSessionPage> {
  /// 기록 화면용 페이지 조회.
  /// 인증 모드: 서버 GET /api/timer-sessions?page=N&size=20
  /// 게스트 모드: 로컬 전체 세션을 startedAt 내림차순 정렬 후 클라이언트 슬라이스.
  ///
  /// Copied from [timerHistoryPage].
  TimerHistoryPageProvider(int page)
    : this._internal(
        (ref) => timerHistoryPage(ref as TimerHistoryPageRef, page),
        from: timerHistoryPageProvider,
        name: r'timerHistoryPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timerHistoryPageHash,
        dependencies: TimerHistoryPageFamily._dependencies,
        allTransitiveDependencies:
            TimerHistoryPageFamily._allTransitiveDependencies,
        page: page,
      );

  TimerHistoryPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  Override overrideWith(
    FutureOr<TimerSessionPage> Function(TimerHistoryPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimerHistoryPageProvider._internal(
        (ref) => create(ref as TimerHistoryPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimerSessionPage> createElement() {
    return _TimerHistoryPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimerHistoryPageProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimerHistoryPageRef on AutoDisposeFutureProviderRef<TimerSessionPage> {
  /// The parameter `page` of this provider.
  int get page;
}

class _TimerHistoryPageProviderElement
    extends AutoDisposeFutureProviderElement<TimerSessionPage>
    with TimerHistoryPageRef {
  _TimerHistoryPageProviderElement(super.provider);

  @override
  int get page => (origin as TimerHistoryPageProvider).page;
}

String _$sortedDateGroupsHash() => r'a7aa65fdd57b7cb8499e396e374719f137d9bb61';

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
    r'8302c3e4c603834a2c5bb618c79ed04d570fb1d0';

/// See also [TimerSessionListNotifier].
@ProviderFor(TimerSessionListNotifier)
final timerSessionListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
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
    AutoDisposeAsyncNotifier<List<TimerSessionEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
