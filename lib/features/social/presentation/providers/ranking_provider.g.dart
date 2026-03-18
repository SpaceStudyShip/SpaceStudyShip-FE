// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rankingListHash() => r'145a899162a07d9bfb466183518f53753e28e489';

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

/// See also [rankingList].
@ProviderFor(rankingList)
const rankingListProvider = RankingListFamily();

/// See also [rankingList].
class RankingListFamily extends Family<List<RankingEntryEntity>> {
  /// See also [rankingList].
  const RankingListFamily();

  /// See also [rankingList].
  RankingListProvider call(RankingType type, RankingPeriod period) {
    return RankingListProvider(type, period);
  }

  @override
  RankingListProvider getProviderOverride(
    covariant RankingListProvider provider,
  ) {
    return call(provider.type, provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rankingListProvider';
}

/// See also [rankingList].
class RankingListProvider
    extends AutoDisposeProvider<List<RankingEntryEntity>> {
  /// See also [rankingList].
  RankingListProvider(RankingType type, RankingPeriod period)
    : this._internal(
        (ref) => rankingList(ref as RankingListRef, type, period),
        from: rankingListProvider,
        name: r'rankingListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rankingListHash,
        dependencies: RankingListFamily._dependencies,
        allTransitiveDependencies: RankingListFamily._allTransitiveDependencies,
        type: type,
        period: period,
      );

  RankingListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
    required this.period,
  }) : super.internal();

  final RankingType type;
  final RankingPeriod period;

  @override
  Override overrideWith(
    List<RankingEntryEntity> Function(RankingListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RankingListProvider._internal(
        (ref) => create(ref as RankingListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<RankingEntryEntity>> createElement() {
    return _RankingListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RankingListProvider &&
        other.type == type &&
        other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RankingListRef on AutoDisposeProviderRef<List<RankingEntryEntity>> {
  /// The parameter `type` of this provider.
  RankingType get type;

  /// The parameter `period` of this provider.
  RankingPeriod get period;
}

class _RankingListProviderElement
    extends AutoDisposeProviderElement<List<RankingEntryEntity>>
    with RankingListRef {
  _RankingListProviderElement(super.provider);

  @override
  RankingType get type => (origin as RankingListProvider).type;
  @override
  RankingPeriod get period => (origin as RankingListProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
