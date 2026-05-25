// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fuelLocalDataSourceHash() =>
    r'6744a9e35144df4f110e8c580674772e4c2b6909';

/// See also [fuelLocalDataSource].
@ProviderFor(fuelLocalDataSource)
final fuelLocalDataSourceProvider = Provider<FuelLocalDataSource>.internal(
  fuelLocalDataSource,
  name: r'fuelLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fuelLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelLocalDataSourceRef = ProviderRef<FuelLocalDataSource>;
String _$fuelRemoteDataSourceHash() =>
    r'ea33b7e9ba3c853a7744f226045c8fa9571a97fb';

/// See also [fuelRemoteDataSource].
@ProviderFor(fuelRemoteDataSource)
final fuelRemoteDataSourceProvider = Provider<FuelRemoteDataSource>.internal(
  fuelRemoteDataSource,
  name: r'fuelRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fuelRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelRemoteDataSourceRef = ProviderRef<FuelRemoteDataSource>;
String _$fuelRepositoryHash() => r'c6f1519b52d17ff64169b7a8162c7ff514616e8d';

/// See also [fuelRepository].
@ProviderFor(fuelRepository)
final fuelRepositoryProvider = Provider<FuelRepository>.internal(
  fuelRepository,
  name: r'fuelRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fuelRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelRepositoryRef = ProviderRef<FuelRepository>;
String _$fuelTransactionsPageHash() =>
    r'425491732e4337666f2fca8517b6a52d191251b0';

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

/// See also [fuelTransactionsPage].
@ProviderFor(fuelTransactionsPage)
const fuelTransactionsPageProvider = FuelTransactionsPageFamily();

/// See also [fuelTransactionsPage].
class FuelTransactionsPageFamily
    extends Family<AsyncValue<FuelTransactionPage>> {
  /// See also [fuelTransactionsPage].
  const FuelTransactionsPageFamily();

  /// See also [fuelTransactionsPage].
  FuelTransactionsPageProvider call(FuelTransactionFilter filter) {
    return FuelTransactionsPageProvider(filter);
  }

  @override
  FuelTransactionsPageProvider getProviderOverride(
    covariant FuelTransactionsPageProvider provider,
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
  String? get name => r'fuelTransactionsPageProvider';
}

/// See also [fuelTransactionsPage].
class FuelTransactionsPageProvider
    extends AutoDisposeFutureProvider<FuelTransactionPage> {
  /// See also [fuelTransactionsPage].
  FuelTransactionsPageProvider(FuelTransactionFilter filter)
    : this._internal(
        (ref) => fuelTransactionsPage(ref as FuelTransactionsPageRef, filter),
        from: fuelTransactionsPageProvider,
        name: r'fuelTransactionsPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelTransactionsPageHash,
        dependencies: FuelTransactionsPageFamily._dependencies,
        allTransitiveDependencies:
            FuelTransactionsPageFamily._allTransitiveDependencies,
        filter: filter,
      );

  FuelTransactionsPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final FuelTransactionFilter filter;

  @override
  Override overrideWith(
    FutureOr<FuelTransactionPage> Function(FuelTransactionsPageRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelTransactionsPageProvider._internal(
        (ref) => create(ref as FuelTransactionsPageRef),
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
  AutoDisposeFutureProviderElement<FuelTransactionPage> createElement() {
    return _FuelTransactionsPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelTransactionsPageProvider && other.filter == filter;
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
mixin FuelTransactionsPageRef
    on AutoDisposeFutureProviderRef<FuelTransactionPage> {
  /// The parameter `filter` of this provider.
  FuelTransactionFilter get filter;
}

class _FuelTransactionsPageProviderElement
    extends AutoDisposeFutureProviderElement<FuelTransactionPage>
    with FuelTransactionsPageRef {
  _FuelTransactionsPageProviderElement(super.provider);

  @override
  FuelTransactionFilter get filter =>
      (origin as FuelTransactionsPageProvider).filter;
}

String _$currentFuelHash() => r'fd59a119f283a5486dcd9d7c0a955800aec3cd51';

/// See also [currentFuel].
@ProviderFor(currentFuel)
final currentFuelProvider = AutoDisposeProvider<AsyncValue<int>>.internal(
  currentFuel,
  name: r'currentFuelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentFuelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFuelRef = AutoDisposeProviderRef<AsyncValue<int>>;
String _$fuelNotifierHash() => r'1c00424056b20144ea6f72e33da9531a3b14cfd4';

/// See also [FuelNotifier].
@ProviderFor(FuelNotifier)
final fuelNotifierProvider =
    AsyncNotifierProvider<FuelNotifier, FuelEntity>.internal(
      FuelNotifier.new,
      name: r'fuelNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fuelNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FuelNotifier = AsyncNotifier<FuelEntity>;
String _$fuelTransactionListNotifierHash() =>
    r'918b56c2d863103920b12ef352fc8a9c9da44d9e';

/// See also [FuelTransactionListNotifier].
@ProviderFor(FuelTransactionListNotifier)
final fuelTransactionListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      FuelTransactionListNotifier,
      List<FuelTransactionEntity>
    >.internal(
      FuelTransactionListNotifier.new,
      name: r'fuelTransactionListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fuelTransactionListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FuelTransactionListNotifier =
    AutoDisposeAsyncNotifier<List<FuelTransactionEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
