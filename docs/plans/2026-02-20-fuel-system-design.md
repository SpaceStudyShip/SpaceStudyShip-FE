# 연료(Fuel) 시스템 설계

**날짜**: 2026-02-20
**이슈**: #41 앱 전체 연료(Fuel) 시스템 구축
**브랜치**: `20260220_#41_앱_전체_연료_Fuel_시스템_구축`

---

## 요구사항

| 항목 | 결정 |
|------|------|
| 충전 규칙 | 30분 공부 = 1통 (시간 비례) |
| 최대 보유량 | 무제한 |
| Todo 보너스 | 없음 (공부 시간만) |
| 이력 기록 | 충전/소비 로그 저장 |
| 저장소 | SharedPreferences (게스트) / 향후 백엔드 API (소셜 로그인) |

## 아키텍처

- **접근 방식**: 독립 Feature (`features/fuel/`)
- **패턴**: 기존 timer/todo와 동일한 Clean Architecture 3-Layer
- **의존성 역전**: Repository 인터페이스는 Domain에, 구현체는 Data에
- **데이터소스 교체**: 게스트(Local) / 로그인(Remote) 분기 가능한 구조

## 파일 구조

```
features/fuel/
├── data/
│   ├── datasources/
│   │   └── fuel_local_datasource.dart
│   ├── models/
│   │   ├── fuel_model.dart (+.freezed +.g)
│   │   └── fuel_transaction_model.dart (+.freezed +.g)
│   └── repositories/
│       └── fuel_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── fuel_entity.dart (+.freezed)
│   │   └── fuel_transaction_entity.dart (+.freezed +enum)
│   ├── repositories/
│   │   └── fuel_repository.dart (abstract)
│   └── usecases/
│       ├── charge_fuel_usecase.dart
│       ├── consume_fuel_usecase.dart
│       └── get_fuel_usecase.dart
└── presentation/
    └── providers/
        └── fuel_provider.dart (+.g)
```

---

## Domain 레이어

### FuelEntity

```dart
@freezed
class FuelEntity with _$FuelEntity {
  const factory FuelEntity({
    @Default(0.0) double currentFuel,      // 현재 보유량 (통)
    @Default(0.0) double totalCharged,     // 누적 충전량
    @Default(0.0) double totalConsumed,    // 누적 소비량
    required DateTime lastUpdatedAt,       // 마지막 갱신 시각
  }) = _FuelEntity;
}
```

### FuelTransactionEntity

```dart
enum FuelTransactionType { charge, consume }
enum FuelTransactionReason { studySession, explorationUnlock }

@freezed
class FuelTransactionEntity with _$FuelTransactionEntity {
  const factory FuelTransactionEntity({
    required String id,
    required FuelTransactionType type,
    required double amount,                 // 변동량 (항상 양수)
    required FuelTransactionReason reason,
    String? referenceId,                    // 관련 세션/노드 ID
    required double balanceAfter,           // 변동 후 잔량
    required DateTime createdAt,
  }) = _FuelTransactionEntity;
}
```

### FuelRepository (abstract)

```dart
abstract class FuelRepository {
  FuelEntity getFuel();
  FuelEntity chargeFuel(double amount, FuelTransactionReason reason, [String? referenceId]);
  FuelEntity consumeFuel(double amount, FuelTransactionReason reason, [String? referenceId]);
  bool canConsume(double amount);
  List<FuelTransactionEntity> getTransactions({int? limit});
}
```

### UseCases

```dart
class ChargeFuelUseCase {
  final FuelRepository _repository;
  ChargeFuelUseCase(this._repository);
  FuelEntity execute(double amount, FuelTransactionReason reason, [String? referenceId]);
}

class ConsumeFuelUseCase {
  final FuelRepository _repository;
  ConsumeFuelUseCase(this._repository);
  FuelEntity execute(double amount, FuelTransactionReason reason, [String? referenceId]);
}

class GetFuelUseCase {
  final FuelRepository _repository;
  GetFuelUseCase(this._repository);
  FuelEntity execute();
}
```

---

## Data 레이어

### FuelModel (Freezed + JSON)

FuelEntity/FuelTransactionEntity 대응 DTO. `toEntity()` / `toModel()` 확장 메서드로 변환.

### FuelLocalDataSource (SharedPreferences)

```dart
class FuelLocalDataSource {
  static const _fuelKey = 'guest_fuel_data';
  static const _transactionsKey = 'guest_fuel_transactions';

  final SharedPreferences _prefs;

  FuelModel getFuel();
  Future<void> saveFuel(FuelModel fuel);
  List<FuelTransactionModel> getTransactions();
  Future<void> addTransaction(FuelTransactionModel transaction);
}
```

### FuelRepositoryImpl

```dart
class FuelRepositoryImpl implements FuelRepository {
  final FuelLocalDataSource _localDataSource;
  // 향후: final FuelRemoteDataSource? _remoteDataSource;

  // 비즈니스 로직:
  // - chargeFuel: 잔량 증가 + 트랜잭션 기록
  // - consumeFuel: 잔량 차감 + 트랜잭션 기록 (부족 시 예외)
  // - canConsume: 잔량 >= amount 확인
}
```

---

## Presentation 레이어

### Provider 체인

```dart
// 1. DataSource (main.dart에서 override)
@riverpod
FuelLocalDataSource fuelLocalDataSource(Ref ref) => throw StateError('Not initialized');

// 2. Repository
@riverpod
FuelRepository fuelRepository(Ref ref) {
  final dataSource = ref.watch(fuelLocalDataSourceProvider);
  return FuelRepositoryImpl(dataSource);
}

// 3. UseCases
@riverpod
ChargeFuelUseCase chargeFuelUseCase(Ref ref) => ChargeFuelUseCase(ref.watch(fuelRepositoryProvider));

@riverpod
ConsumeFuelUseCase consumeFuelUseCase(Ref ref) => ConsumeFuelUseCase(ref.watch(fuelRepositoryProvider));

// 4. State Notifier
@Riverpod(keepAlive: true)
class FuelNotifier extends _$FuelNotifier {
  @override
  FuelEntity build() => ref.watch(fuelRepositoryProvider).getFuel();

  void chargeFuel({required int studyMinutes, String? sessionId}) {
    final amount = studyMinutes / 30.0;  // 30분 = 1통
    final useCase = ref.read(chargeFuelUseCaseProvider);
    state = useCase.execute(amount, FuelTransactionReason.studySession, sessionId);
  }

  void consumeFuel({required double amount, String? nodeId}) {
    final useCase = ref.read(consumeFuelUseCaseProvider);
    state = useCase.execute(amount, FuelTransactionReason.explorationUnlock, nodeId);
  }
}

// 5. 이력 Notifier
@riverpod
class FuelTransactionListNotifier extends _$FuelTransactionListNotifier {
  @override
  List<FuelTransactionEntity> build() => ref.watch(fuelRepositoryProvider).getTransactions();

  void refresh() { state = ref.read(fuelRepositoryProvider).getTransactions(); }
}

// 6. 편의 Provider
@riverpod
double currentFuel(Ref ref) => ref.watch(fuelNotifierProvider).currentFuel;

@riverpod
bool canUnlock(Ref ref, double requiredFuel) => ref.watch(fuelNotifierProvider).currentFuel >= requiredFuel;
```

---

## 연동 포인트

### 타이머 → 연료 충전

`TimerProvider.stopTimer()` 에서 세션 저장 후:
```dart
ref.read(fuelNotifierProvider.notifier).chargeFuel(
  studyMinutes: durationMinutes,
  sessionId: session.id,
);
```

### 탐험 → 연료 소비

`ExplorationDetailScreen` 해금 시:
```dart
ref.read(fuelNotifierProvider.notifier).consumeFuel(
  amount: region.requiredFuel,
  nodeId: region.id,
);
```

### UI 연동

기존 `FuelGauge`, `SpaceshipHeader`, `StatusCard`:
```dart
final fuel = ref.watch(fuelNotifierProvider);
FuelGauge(currentFuel: fuel.currentFuel);
```

---

## 초기화

`main.dart` ProviderScope overrides에 추가:
```dart
fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
```

---

## 향후 확장 (지금 구현 안 함)

- `FuelRemoteDataSource`: 백엔드 API 연동 (소셜 로그인 시)
- `FuelRepositoryImpl` 분기: `isLoggedIn ? remote : local`
- 일일 충전량 제한, 레벨별 보너스 등 추가 규칙
