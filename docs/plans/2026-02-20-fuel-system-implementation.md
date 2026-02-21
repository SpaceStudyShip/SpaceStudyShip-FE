# Fuel System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a complete fuel system where study time charges fuel (30min = 1 barrel) and exploration consumes fuel, with full Clean Architecture layers and SharedPreferences persistence.

**Architecture:** Independent `features/fuel/` feature following the same Clean Architecture 3-Layer pattern as timer/todo. Domain holds abstract Repository interface; Data implements it with LocalDataSource (SharedPreferences). Presentation uses Riverpod Generator with keepAlive state. Dependency inversion allows future Remote DataSource swap for social login.

**Tech Stack:** Flutter, Riverpod 2.6 (Generator), Freezed 2.5, SharedPreferences, build_runner

---

## Task 1: Domain Entities

**Files:**
- Create: `lib/features/fuel/domain/entities/fuel_entity.dart`
- Create: `lib/features/fuel/domain/entities/fuel_transaction_entity.dart`

**Step 1: Create FuelEntity with Freezed**

```dart
// lib/features/fuel/domain/entities/fuel_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_entity.freezed.dart';

@freezed
class FuelEntity with _$FuelEntity {
  const factory FuelEntity({
    @Default(0) int currentFuel,
    @Default(0) int totalCharged,
    @Default(0) int totalConsumed,
    required DateTime lastUpdatedAt,
  }) = _FuelEntity;
}
```

**Step 2: Create FuelTransactionEntity with enums and Freezed**

```dart
// lib/features/fuel/domain/entities/fuel_transaction_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_transaction_entity.freezed.dart';

enum FuelTransactionType { charge, consume }

enum FuelTransactionReason { studySession, explorationUnlock }

@freezed
class FuelTransactionEntity with _$FuelTransactionEntity {
  const factory FuelTransactionEntity({
    required String id,
    required FuelTransactionType type,
    required int amount,
    required FuelTransactionReason reason,
    String? referenceId,
    required int balanceAfter,
    required DateTime createdAt,
  }) = _FuelTransactionEntity;
}
```

**Step 3: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `.freezed.dart` files generated for both entities

**Step 4: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 5: Commit**

```text
feat: 연료 시스템 Domain 엔티티 생성 (FuelEntity, FuelTransactionEntity)
```

---

## Task 2: Domain Repository Interface & UseCases

**Files:**
- Create: `lib/features/fuel/domain/repositories/fuel_repository.dart`
- Create: `lib/features/fuel/domain/usecases/charge_fuel_usecase.dart`
- Create: `lib/features/fuel/domain/usecases/consume_fuel_usecase.dart`
- Create: `lib/features/fuel/domain/usecases/get_fuel_usecase.dart`

**Step 1: Create abstract FuelRepository**

```dart
// lib/features/fuel/domain/repositories/fuel_repository.dart
import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';

abstract class FuelRepository {
  FuelEntity getFuel();
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);
  List<FuelTransactionEntity> getTransactions({int? limit});
  Future<void> clearAll();
}
```

**Step 2: Create UseCases**

```dart
// lib/features/fuel/domain/usecases/charge_fuel_usecase.dart
import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';
import '../repositories/fuel_repository.dart';

class ChargeFuelUseCase {
  final FuelRepository _repository;
  ChargeFuelUseCase(this._repository);

  FuelEntity execute(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    return _repository.chargeFuel(amount, reason, referenceId);
  }
}
```

```dart
// lib/features/fuel/domain/usecases/consume_fuel_usecase.dart
import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';
import '../repositories/fuel_repository.dart';

class ConsumeFuelUseCase {
  final FuelRepository _repository;
  ConsumeFuelUseCase(this._repository);

  FuelEntity execute(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    return _repository.consumeFuel(amount, reason, referenceId);
  }
}
```

```dart
// lib/features/fuel/domain/usecases/get_fuel_usecase.dart
import '../entities/fuel_entity.dart';
import '../repositories/fuel_repository.dart';

class GetFuelUseCase {
  final FuelRepository _repository;
  GetFuelUseCase(this._repository);

  FuelEntity execute() {
    return _repository.getFuel();
  }
}
```

**Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```text
feat: 연료 시스템 Repository 인터페이스 및 UseCase 생성
```

---

## Task 3: Data Models (Freezed + JSON)

**Files:**
- Create: `lib/features/fuel/data/models/fuel_model.dart`
- Create: `lib/features/fuel/data/models/fuel_transaction_model.dart`

**Step 1: Create FuelModel**

Follow the timer_session_model.dart pattern exactly: Freezed + JSON + toEntity/toModel extensions.

```dart
// lib/features/fuel/data/models/fuel_model.dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_entity.dart';

part 'fuel_model.freezed.dart';
part 'fuel_model.g.dart';

@freezed
class FuelModel with _$FuelModel {
  const factory FuelModel({
    @Default(0.0) @JsonKey(name: 'current_fuel') double currentFuel,
    @Default(0.0) @JsonKey(name: 'total_charged') double totalCharged,
    @Default(0.0) @JsonKey(name: 'total_consumed') double totalConsumed,
    @JsonKey(name: 'last_updated_at') required DateTime lastUpdatedAt,
  }) = _FuelModel;

  factory FuelModel.fromJson(Map<String, dynamic> json) =>
      _$FuelModelFromJson(json);
}

extension FuelModelX on FuelModel {
  FuelEntity toEntity() => FuelEntity(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        lastUpdatedAt: lastUpdatedAt,
      );
}

extension FuelEntityX on FuelEntity {
  FuelModel toModel() => FuelModel(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        lastUpdatedAt: lastUpdatedAt,
      );
}
```

**Step 2: Create FuelTransactionModel**

```dart
// lib/features/fuel/data/models/fuel_transaction_model.dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_entity.dart';

part 'fuel_transaction_model.freezed.dart';
part 'fuel_transaction_model.g.dart';

@freezed
class FuelTransactionModel with _$FuelTransactionModel {
  const factory FuelTransactionModel({
    required String id,
    required String type,
    required int amount,
    required String reason,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'balance_after') required double balanceAfter,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FuelTransactionModel;

  factory FuelTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$FuelTransactionModelFromJson(json);
}

extension FuelTransactionModelX on FuelTransactionModel {
  FuelTransactionEntity toEntity() => FuelTransactionEntity(
        id: id,
        type: FuelTransactionType.values.byName(type),
        amount: amount,
        reason: FuelTransactionReason.values.byName(reason),
        referenceId: referenceId,
        balanceAfter: balanceAfter,
        createdAt: createdAt,
      );
}

extension FuelTransactionEntityX on FuelTransactionEntity {
  FuelTransactionModel toModel() => FuelTransactionModel(
        id: id,
        type: type.name,
        amount: amount,
        reason: reason.name,
        referenceId: referenceId,
        balanceAfter: balanceAfter,
        createdAt: createdAt,
      );
}
```

**Step 3: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `.freezed.dart` and `.g.dart` files generated

**Step 4: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 5: Commit**

```text
feat: 연료 시스템 Data 모델 생성 (FuelModel, FuelTransactionModel)
```

---

## Task 4: LocalDataSource (SharedPreferences)

**Files:**
- Create: `lib/features/fuel/data/datasources/fuel_local_datasource.dart`

**Step 1: Create FuelLocalDataSource**

Follow the `timer_session_local_datasource.dart` pattern exactly.

```dart
// lib/features/fuel/data/datasources/fuel_local_datasource.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_model.dart';
import '../models/fuel_transaction_model.dart';

class FuelLocalDataSource {
  static const _fuelKey = 'guest_fuel_data';
  static const _transactionsKey = 'guest_fuel_transactions';

  final SharedPreferences _prefs;

  FuelLocalDataSource(this._prefs);

  FuelModel getFuel() {
    final jsonString = _prefs.getString(_fuelKey);
    if (jsonString == null) {
      return FuelModel(lastUpdatedAt: DateTime.now());
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FuelModel.fromJson(json);
    } catch (_) {
      _prefs.remove(_fuelKey);
      return FuelModel(lastUpdatedAt: DateTime.now());
    }
  }

  Future<void> saveFuel(FuelModel fuel) async {
    final jsonString = jsonEncode(fuel.toJson());
    await _prefs.setString(_fuelKey, jsonString);
  }

  List<FuelTransactionModel> getTransactions() {
    final jsonString = _prefs.getString(_transactionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => FuelTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_transactionsKey);
      return [];
    }
  }

  Future<void> saveTransactions(List<FuelTransactionModel> transactions) async {
    final jsonString =
        jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionsKey, jsonString);
  }

  Future<void> addTransaction(FuelTransactionModel transaction) async {
    final transactions = getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  Future<void> clearAll() async {
    final txCount = getTransactions().length;
    await _prefs.remove(_fuelKey);
    await _prefs.remove(_transactionsKey);
    debugPrint('🧹 Fuel 캐시 삭제 완료 (삭제된 트랜잭션: $txCount개)');
  }
}
```

**Step 2: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```text
feat: 연료 시스템 LocalDataSource 생성 (SharedPreferences)
```

---

## Task 5: Repository Implementation

**Files:**
- Create: `lib/features/fuel/data/repositories/fuel_repository_impl.dart`

**Step 1: Create FuelRepositoryImpl**

```dart
// lib/features/fuel/data/repositories/fuel_repository_impl.dart
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_datasource.dart';
import '../models/fuel_model.dart';
import '../models/fuel_transaction_model.dart';

class FuelRepositoryImpl implements FuelRepository {
  final FuelLocalDataSource _localDataSource;

  FuelRepositoryImpl(this._localDataSource);

  @override
  FuelEntity getFuel() {
    return _localDataSource.getFuel().toEntity();
  }

  @override
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    final newFuel = FuelModel(
      currentFuel: current.currentFuel + amount,
      totalCharged: current.totalCharged + amount,
      totalConsumed: current.totalConsumed,
      pendingMinutes: pendingMinutes,
      lastUpdatedAt: DateTime.now(),
    );

    await _localDataSource.saveFuel(newFuel);

    final transaction = FuelTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: FuelTransactionType.charge.name,
      amount: amount,
      reason: reason.name,
      referenceId: referenceId,
      balanceAfter: newFuel.currentFuel,
      createdAt: DateTime.now(),
    );
    await _localDataSource.addTransaction(transaction);

    return newFuel.toEntity();
  }

  @override
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    if (current.currentFuel < amount) {
      throw InsufficientFuelException(
        requiredAmount: amount,
        available: current.currentFuel,
      );
    }

    final newFuel = FuelModel(
      currentFuel: current.currentFuel - amount,
      totalCharged: current.totalCharged,
      totalConsumed: current.totalConsumed + amount,
      lastUpdatedAt: DateTime.now(),
    );

    await _localDataSource.saveFuel(newFuel);

    final transaction = FuelTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: FuelTransactionType.consume.name,
      amount: amount,
      reason: reason.name,
      referenceId: referenceId,
      balanceAfter: newFuel.currentFuel,
      createdAt: DateTime.now(),
    );
    await _localDataSource.addTransaction(transaction);

    return newFuel.toEntity();
  }

  @override
  List<FuelTransactionEntity> getTransactions({int? limit}) {
    final transactions = _localDataSource
        .getTransactions()
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && transactions.length > limit) {
      return transactions.sublist(0, limit);
    }
    return transactions;
  }
}

class InsufficientFuelException implements Exception {
  final int requiredAmount;
  final int available;

  InsufficientFuelException({
    required this.requiredAmount,
    required this.available,
  });

  @override
  String toString() => '연료가 부족합니다 (필요: $requiredAmount통, 보유: $available통)';
}
```

**Step 2: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```text
feat: 연료 시스템 Repository 구현체 생성
```

---

## Task 6: Riverpod Providers

**Files:**
- Create: `lib/features/fuel/presentation/providers/fuel_provider.dart`

**Step 1: Create fuel_provider.dart with full provider chain**

Follow the `timer_session_provider.dart` pattern exactly.

```dart
// lib/features/fuel/presentation/providers/fuel_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/fuel_local_datasource.dart';
import '../../data/repositories/fuel_repository_impl.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../../domain/usecases/charge_fuel_usecase.dart';
import '../../domain/usecases/consume_fuel_usecase.dart';

part 'fuel_provider.g.dart';

// === DataSource & Repository ===

@riverpod
FuelLocalDataSource fuelLocalDataSource(Ref ref) {
  throw StateError(
    'FuelLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
FuelRepository fuelRepository(Ref ref) {
  final dataSource = ref.watch(fuelLocalDataSourceProvider);
  return FuelRepositoryImpl(dataSource);
}

// === UseCases ===

@riverpod
ChargeFuelUseCase chargeFuelUseCase(Ref ref) {
  return ChargeFuelUseCase(ref.watch(fuelRepositoryProvider));
}

@riverpod
ConsumeFuelUseCase consumeFuelUseCase(Ref ref) {
  return ConsumeFuelUseCase(ref.watch(fuelRepositoryProvider));
}

// === Fuel State ===

@Riverpod(keepAlive: true)
class FuelNotifier extends _$FuelNotifier {
  @override
  FuelEntity build() {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getFuel();
  }

  /// 공부 시간으로 연료 충전 (30분 = 1통)
  void chargeFuel({required int studyMinutes, String? sessionId}) {
    if (studyMinutes <= 0) return;
    final amount = studyMinutes ~/ 30;
    final useCase = ref.read(chargeFuelUseCaseProvider);
    state = useCase.execute(
      amount,
      FuelTransactionReason.studySession,
      sessionId,
    );
    // 이력도 갱신
    ref.invalidate(fuelTransactionListNotifierProvider);
  }

  /// 탐험 해금 등으로 연료 소비
  void consumeFuel({required int amount, String? nodeId}) {
    final useCase = ref.read(consumeFuelUseCaseProvider);
    state = useCase.execute(
      amount,
      FuelTransactionReason.explorationUnlock,
      nodeId,
    );
    // 이력도 갱신
    ref.invalidate(fuelTransactionListNotifierProvider);
  }
}

// === Transaction History ===

@riverpod
class FuelTransactionListNotifier extends _$FuelTransactionListNotifier {
  @override
  List<FuelTransactionEntity> build() {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getTransactions();
  }
}

// === Convenience Providers ===

@riverpod
int currentFuel(Ref ref) {
  return ref.watch(fuelNotifierProvider).currentFuel;
}

@riverpod
bool canUnlock(Ref ref, int requiredFuel) {
  return ref.watch(fuelNotifierProvider).currentFuel >= requiredFuel;
}
```

**Step 2: Run build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `fuel_provider.g.dart` generated

**Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```text
feat: 연료 시스템 Riverpod Provider 체인 생성
```

---

## Task 7: Initialize in main.dart

**Files:**
- Modify: `lib/main.dart:18-21` (imports) and `lib/main.dart:184-193` (overrides)

**Step 1: Add import**

Add after existing timer import (line ~18):
```dart
import 'features/fuel/data/datasources/fuel_local_datasource.dart';
import 'features/fuel/presentation/providers/fuel_provider.dart';
```

**Step 2: Add override in ProviderScope**

Add to the overrides list in `ProviderScope` (after the timerSessionLocalDataSourceProvider override, around line 192):
```dart
if (prefs != null)
  fuelLocalDataSourceProvider.overrideWithValue(
    FuelLocalDataSource(prefs),
  ),
```

**Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```text
feat: main.dart에 연료 DataSource 초기화 추가
```

---

## Task 8: Timer → Fuel Charge Integration

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart:1-10` (imports) and `:93-113` (stop method)

**Step 1: Add import**

Add after existing imports (around line 8):
```dart
import '../../../fuel/presentation/providers/fuel_provider.dart';
```

**Step 2: Add fuel charge after session save**

In the `stop()` method, after the session save block (`await ref.read(timerSessionListNotifierProvider.notifier).addSession(session);`, around line 112), add fuel charging:

```dart
// 연료 충전 (30분 = 1통)
ref.read(fuelNotifierProvider.notifier).chargeFuel(
  studyMinutes: elapsedMinutes,
  sessionId: session.id,
);
```

This should be placed inside the `if (sessionDuration.inMinutes >= 1)` block, after `addSession`.

**Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```text
feat: 타이머 세션 완료 시 연료 자동 충전 연동
```

---

## Task 9: Exploration UI → Fuel Provider Integration

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart:33` (hardcoded fuel)
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart:30` (hardcoded fuel)

**Step 1: Update explore_screen.dart**

Convert `ExploreScreen` from `StatelessWidget` to `ConsumerWidget` (or add ConsumerWidget mixin). Replace hardcoded fuel:

Change the class declaration:
```dart
class ExploreScreen extends ConsumerWidget {
```

Update the `build` method signature:
```dart
Widget build(BuildContext context, WidgetRef ref) {
```

Replace `final currentFuel = 3.5;` (line 33) with:
```dart
final currentFuel = ref.watch(currentFuelProvider);
```

Add import at top:
```dart
import '../../../fuel/presentation/providers/fuel_provider.dart';
```

Also add `flutter_riverpod` import:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

**Step 2: Update exploration_detail_screen.dart**

Convert `ExplorationDetailScreen` from `StatelessWidget` to `ConsumerWidget`.

Change the class declaration:
```dart
class ExplorationDetailScreen extends ConsumerWidget {
```

Update the `build` method signature:
```dart
Widget build(BuildContext context, WidgetRef ref) {
```

Replace `final currentFuel = 3.5;` (line 30) with:
```dart
final currentFuel = ref.watch(currentFuelProvider);
```

In `_handleUnlock`, update to actually consume fuel. The method needs `WidgetRef ref` parameter. Update the `onPressed` in the dialog (around line 251-259) to:
```dart
onPressed: () {
  Navigator.of(ctx).pop();
  try {
    ref.read(fuelNotifierProvider.notifier).consumeFuel(
      amount: region.requiredFuel,
      nodeId: region.id,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${region.name}이(가) 해금되었습니다! 🎉'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
},
```

Add imports at top:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
```

**Step 3: Verify with flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```text
feat: 탐험 화면에 실제 연료 데이터 연동 (하드코딩 제거)
```

---

## Task 10: Home Screen Fuel Display Integration

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart` (if fuel display exists or is needed)

**Note:** The home screen currently does NOT display fuel directly - it uses `SpaceshipHeader` which receives `fuel` as a prop. The `SpaceshipHeader` is not used in the current `home_screen.dart` (it was replaced with a simpler spaceship area). No changes needed here for MVP since there's no fuel display on the current home screen.

If fuel display should be added to the home screen's AppBar or elsewhere, that would be a separate UI task. Skip this task if not needed.

**Step 1: Verify no home screen changes needed**

Confirm that `home_screen.dart` does not reference fuel or FuelGauge directly. If it does, connect to `currentFuelProvider`.

**Step 2: Commit (if changes made)**

```text
feat: 홈 화면 연료 표시 연동
```

---

## Task 11: Final Verification & Cleanup

**Step 1: Run build_runner (final)**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: All generated files up to date

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Verify file structure**

Confirm the following files exist:
```text
lib/features/fuel/
├── data/
│   ├── datasources/
│   │   └── fuel_local_datasource.dart
│   ├── models/
│   │   ├── fuel_model.dart
│   │   ├── fuel_model.freezed.dart
│   │   ├── fuel_model.g.dart
│   │   ├── fuel_transaction_model.dart
│   │   ├── fuel_transaction_model.freezed.dart
│   │   └── fuel_transaction_model.g.dart
│   └── repositories/
│       └── fuel_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── fuel_entity.dart
│   │   ├── fuel_entity.freezed.dart
│   │   ├── fuel_transaction_entity.dart
│   │   └── fuel_transaction_entity.freezed.dart
│   ├── repositories/
│   │   └── fuel_repository.dart
│   └── usecases/
│       ├── charge_fuel_usecase.dart
│       ├── consume_fuel_usecase.dart
│       └── get_fuel_usecase.dart
└── presentation/
    └── providers/
        ├── fuel_provider.dart
        └── fuel_provider.g.dart
```

**Step 4: Final commit (if any cleanup needed)**

```text
chore: 연료 시스템 최종 정리
```
