// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exploration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$explorationLocalDataSourceHash() =>
    r'567e212403f8e59683082c9accdcd064dde41e60';

/// 기본값: StateError (main.dart에서 SharedPreferences로 override 필수)
///
/// Copied from [explorationLocalDataSource].
@ProviderFor(explorationLocalDataSource)
final explorationLocalDataSourceProvider =
    AutoDisposeProvider<ExplorationLocalDataSource>.internal(
      explorationLocalDataSource,
      name: r'explorationLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$explorationLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExplorationLocalDataSourceRef =
    AutoDisposeProviderRef<ExplorationLocalDataSource>;
String _$explorationRemoteDataSourceHash() =>
    r'2c06143a1f3225df177493831d068e4c49ad1570';

/// See also [explorationRemoteDataSource].
@ProviderFor(explorationRemoteDataSource)
final explorationRemoteDataSourceProvider =
    Provider<ExplorationRemoteDataSource>.internal(
      explorationRemoteDataSource,
      name: r'explorationRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$explorationRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExplorationRemoteDataSourceRef =
    ProviderRef<ExplorationRemoteDataSource>;
String _$explorationRepositoryHash() =>
    r'cc330188bf19edd52acd58225758621eada93bbc';

/// 인증 사용자는 서버, 게스트는 로컬 Repository.
///
/// Copied from [explorationRepository].
@ProviderFor(explorationRepository)
final explorationRepositoryProvider = Provider<ExplorationRepository>.internal(
  explorationRepository,
  name: r'explorationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$explorationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExplorationRepositoryRef = ProviderRef<ExplorationRepository>;
String _$explorationProgressHash() =>
    r'fed6d083e814c046242a76f06f72f82eb594dbc3';

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

/// 특정 행성의 진행도.
///
/// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
/// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
/// 행성 응답에 내장.)
///
/// Copied from [explorationProgress].
@ProviderFor(explorationProgress)
const explorationProgressProvider = ExplorationProgressFamily();

/// 특정 행성의 진행도.
///
/// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
/// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
/// 행성 응답에 내장.)
///
/// Copied from [explorationProgress].
class ExplorationProgressFamily
    extends Family<AsyncValue<ExplorationProgressEntity>> {
  /// 특정 행성의 진행도.
  ///
  /// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
  /// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
  /// 행성 응답에 내장.)
  ///
  /// Copied from [explorationProgress].
  const ExplorationProgressFamily();

  /// 특정 행성의 진행도.
  ///
  /// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
  /// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
  /// 행성 응답에 내장.)
  ///
  /// Copied from [explorationProgress].
  ExplorationProgressProvider call(String planetId) {
    return ExplorationProgressProvider(planetId);
  }

  @override
  ExplorationProgressProvider getProviderOverride(
    covariant ExplorationProgressProvider provider,
  ) {
    return call(provider.planetId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'explorationProgressProvider';
}

/// 특정 행성의 진행도.
///
/// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
/// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
/// 행성 응답에 내장.)
///
/// Copied from [explorationProgress].
class ExplorationProgressProvider
    extends AutoDisposeFutureProvider<ExplorationProgressEntity> {
  /// 특정 행성의 진행도.
  ///
  /// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
  /// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
  /// 행성 응답에 내장.)
  ///
  /// Copied from [explorationProgress].
  ExplorationProgressProvider(String planetId)
    : this._internal(
        (ref) => explorationProgress(ref as ExplorationProgressRef, planetId),
        from: explorationProgressProvider,
        name: r'explorationProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$explorationProgressHash,
        dependencies: ExplorationProgressFamily._dependencies,
        allTransitiveDependencies:
            ExplorationProgressFamily._allTransitiveDependencies,
        planetId: planetId,
      );

  ExplorationProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planetId,
  }) : super.internal();

  final String planetId;

  @override
  Override overrideWith(
    FutureOr<ExplorationProgressEntity> Function(
      ExplorationProgressRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExplorationProgressProvider._internal(
        (ref) => create(ref as ExplorationProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planetId: planetId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExplorationProgressEntity> createElement() {
    return _ExplorationProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplorationProgressProvider && other.planetId == planetId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planetId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExplorationProgressRef
    on AutoDisposeFutureProviderRef<ExplorationProgressEntity> {
  /// The parameter `planetId` of this provider.
  String get planetId;
}

class _ExplorationProgressProviderElement
    extends AutoDisposeFutureProviderElement<ExplorationProgressEntity>
    with ExplorationProgressRef {
  _ExplorationProgressProviderElement(super.provider);

  @override
  String get planetId => (origin as ExplorationProgressProvider).planetId;
}

String _$explorationNotifierHash() =>
    r'd1d397d7c30fcb66b595cadda5bce2834e82ebec';

/// 행성 목록 상태
///
/// 게스트/소셜 로그인 모두 전체 행성을 표시합니다.
/// 게스트의 비-지구 행성 접근 제한은 UI(explore_screen)에서 처리합니다.
///
/// Copied from [ExplorationNotifier].
@ProviderFor(ExplorationNotifier)
final explorationNotifierProvider =
    AsyncNotifierProvider<
      ExplorationNotifier,
      List<ExplorationNodeEntity>
    >.internal(
      ExplorationNotifier.new,
      name: r'explorationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$explorationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExplorationNotifier = AsyncNotifier<List<ExplorationNodeEntity>>;
String _$regionListNotifierHash() =>
    r'582db187507042692eaf6acdd6bbe6ec0c4f8afe';

abstract class _$RegionListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ExplorationNodeEntity>> {
  late final String planetId;

  FutureOr<List<ExplorationNodeEntity>> build(String planetId);
}

/// 특정 행성의 지역 목록 (행성 ID 기반 family)
///
/// Copied from [RegionListNotifier].
@ProviderFor(RegionListNotifier)
const regionListNotifierProvider = RegionListNotifierFamily();

/// 특정 행성의 지역 목록 (행성 ID 기반 family)
///
/// Copied from [RegionListNotifier].
class RegionListNotifierFamily
    extends Family<AsyncValue<List<ExplorationNodeEntity>>> {
  /// 특정 행성의 지역 목록 (행성 ID 기반 family)
  ///
  /// Copied from [RegionListNotifier].
  const RegionListNotifierFamily();

  /// 특정 행성의 지역 목록 (행성 ID 기반 family)
  ///
  /// Copied from [RegionListNotifier].
  RegionListNotifierProvider call(String planetId) {
    return RegionListNotifierProvider(planetId);
  }

  @override
  RegionListNotifierProvider getProviderOverride(
    covariant RegionListNotifierProvider provider,
  ) {
    return call(provider.planetId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'regionListNotifierProvider';
}

/// 특정 행성의 지역 목록 (행성 ID 기반 family)
///
/// Copied from [RegionListNotifier].
class RegionListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RegionListNotifier,
          List<ExplorationNodeEntity>
        > {
  /// 특정 행성의 지역 목록 (행성 ID 기반 family)
  ///
  /// Copied from [RegionListNotifier].
  RegionListNotifierProvider(String planetId)
    : this._internal(
        () => RegionListNotifier()..planetId = planetId,
        from: regionListNotifierProvider,
        name: r'regionListNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$regionListNotifierHash,
        dependencies: RegionListNotifierFamily._dependencies,
        allTransitiveDependencies:
            RegionListNotifierFamily._allTransitiveDependencies,
        planetId: planetId,
      );

  RegionListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planetId,
  }) : super.internal();

  final String planetId;

  @override
  FutureOr<List<ExplorationNodeEntity>> runNotifierBuild(
    covariant RegionListNotifier notifier,
  ) {
    return notifier.build(planetId);
  }

  @override
  Override overrideWith(RegionListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RegionListNotifierProvider._internal(
        () => create()..planetId = planetId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planetId: planetId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    RegionListNotifier,
    List<ExplorationNodeEntity>
  >
  createElement() {
    return _RegionListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RegionListNotifierProvider && other.planetId == planetId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planetId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RegionListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ExplorationNodeEntity>> {
  /// The parameter `planetId` of this provider.
  String get planetId;
}

class _RegionListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          RegionListNotifier,
          List<ExplorationNodeEntity>
        >
    with RegionListNotifierRef {
  _RegionListNotifierProviderElement(super.provider);

  @override
  String get planetId => (origin as RegionListNotifierProvider).planetId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
