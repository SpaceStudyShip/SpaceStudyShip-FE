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
String _$fuelRepositoryHash() => r'e39729195218df769eabf37a24db38e9197766ff';

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
String _$currentFuelHash() => r'af37c1ff662f2086faf31b5f0e70e36e52478619';

/// See also [currentFuel].
@ProviderFor(currentFuel)
final currentFuelProvider = AutoDisposeProvider<int>.internal(
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
typedef CurrentFuelRef = AutoDisposeProviderRef<int>;
String _$fuelNotifierHash() => r'7dfe840141f943a55d920d38ef80e8504d4fccd0';

/// See also [FuelNotifier].
@ProviderFor(FuelNotifier)
final fuelNotifierProvider =
    NotifierProvider<FuelNotifier, FuelEntity>.internal(
      FuelNotifier.new,
      name: r'fuelNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fuelNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FuelNotifier = Notifier<FuelEntity>;
String _$fuelTransactionListNotifierHash() =>
    r'f3424c2b23372a381156ab8efcbec55fe278462b';

/// See also [FuelTransactionListNotifier].
@ProviderFor(FuelTransactionListNotifier)
final fuelTransactionListNotifierProvider =
    AutoDisposeNotifierProvider<
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
    AutoDisposeNotifier<List<FuelTransactionEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
