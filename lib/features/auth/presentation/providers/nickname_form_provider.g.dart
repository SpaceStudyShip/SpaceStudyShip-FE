// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nicknameFormNotifierHash() =>
    r'797b8989cd5087c0bff721547ddab8441c6bff95';

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

abstract class _$NicknameFormNotifier
    extends BuildlessAutoDisposeNotifier<NicknameFormState> {
  late final String serverNickname;

  NicknameFormState build(String serverNickname);
}

/// See also [NicknameFormNotifier].
@ProviderFor(NicknameFormNotifier)
const nicknameFormNotifierProvider = NicknameFormNotifierFamily();

/// See also [NicknameFormNotifier].
class NicknameFormNotifierFamily extends Family<NicknameFormState> {
  /// See also [NicknameFormNotifier].
  const NicknameFormNotifierFamily();

  /// See also [NicknameFormNotifier].
  NicknameFormNotifierProvider call(String serverNickname) {
    return NicknameFormNotifierProvider(serverNickname);
  }

  @override
  NicknameFormNotifierProvider getProviderOverride(
    covariant NicknameFormNotifierProvider provider,
  ) {
    return call(provider.serverNickname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nicknameFormNotifierProvider';
}

/// See also [NicknameFormNotifier].
class NicknameFormNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          NicknameFormNotifier,
          NicknameFormState
        > {
  /// See also [NicknameFormNotifier].
  NicknameFormNotifierProvider(String serverNickname)
    : this._internal(
        () => NicknameFormNotifier()..serverNickname = serverNickname,
        from: nicknameFormNotifierProvider,
        name: r'nicknameFormNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$nicknameFormNotifierHash,
        dependencies: NicknameFormNotifierFamily._dependencies,
        allTransitiveDependencies:
            NicknameFormNotifierFamily._allTransitiveDependencies,
        serverNickname: serverNickname,
      );

  NicknameFormNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serverNickname,
  }) : super.internal();

  final String serverNickname;

  @override
  NicknameFormState runNotifierBuild(covariant NicknameFormNotifier notifier) {
    return notifier.build(serverNickname);
  }

  @override
  Override overrideWith(NicknameFormNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: NicknameFormNotifierProvider._internal(
        () => create()..serverNickname = serverNickname,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serverNickname: serverNickname,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<NicknameFormNotifier, NicknameFormState>
  createElement() {
    return _NicknameFormNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NicknameFormNotifierProvider &&
        other.serverNickname == serverNickname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serverNickname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NicknameFormNotifierRef
    on AutoDisposeNotifierProviderRef<NicknameFormState> {
  /// The parameter `serverNickname` of this provider.
  String get serverNickname;
}

class _NicknameFormNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          NicknameFormNotifier,
          NicknameFormState
        >
    with NicknameFormNotifierRef {
  _NicknameFormNotifierProviderElement(super.provider);

  @override
  String get serverNickname =>
      (origin as NicknameFormNotifierProvider).serverNickname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
