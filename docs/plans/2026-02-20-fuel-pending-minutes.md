# 연료 충전 잔여 시간 누적 (pendingMinutes) 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 30분 미만 공부 시 연료 0통 문제를 해결하기 위해 잔여 공부 시간을 누적하여 보상 손실을 방지한다.

**Architecture:** FuelEntity/FuelModel에 `pendingMinutes` 필드를 추가하여 30분 미만 잔여 시간을 저장. Provider의 chargeFuel에서 `(기존 잔여 + 이번 공부시간) ~/ 30`으로 충전량 계산, 나머지는 다시 pendingMinutes에 저장. 충전량 0이어도 pendingMinutes는 업데이트되어 노력이 손실되지 않음.

**Tech Stack:** Flutter, Freezed, Riverpod (Generator), SharedPreferences

---

## 선택 근거

| 옵션 | 설명 | 판정 |
|------|------|------|
| A. 10분=1통 | 충전 단위 축소 + 탐험 비용 3배 증가 | 탐험 비용이 커져 숫자 의미 희석 |
| B. 잔여 시간 누적 | 30분 기준 유지 + 미달 시간 저장 | **채택** - 가장 직관적, 기존 밸런스 유지 |
| C. 15분=1통 | 절충안, 탐험 비용 2배 | 14분은 여전히 0통, 근본 해결 안 됨 |

**옵션 B 장점:**
- "30분 = 1통" 멘탈 모델 유지
- 사용자 노력 100% 보존 (15분 + 20분 = 35분 → 1통 + 잔여 5분)
- 탐험 비용 변경 불필요 (현재 1-4통 범위 유지)
- 마이그레이션 안전 (`@Default(0)`으로 기존 데이터 호환)

---

## 변경 파일 목록 (총 8개 소스 + 생성파일)

| 레이어 | 파일 | 변경 |
|--------|------|------|
| Domain | `fuel_entity.dart` | `pendingMinutes` 필드 추가 |
| Domain | `fuel_repository.dart` | `chargeFuel` 시그니처에 `pendingMinutes` 추가 |
| Domain | `charge_fuel_usecase.dart` | `execute`에 `pendingMinutes` 추가 |
| Data | `fuel_model.dart` | `pendingMinutes` 필드 + JSON key + 매핑 |
| Data | `fuel_repository_impl.dart` | pendingMinutes 저장 + amount=0일 때 트랜잭션 생략 |
| Presentation | `fuel_provider.dart` | 누적 계산 로직 변경 |
| 생성 | `*.freezed.dart`, `*.g.dart` | build_runner 재생성 |

---

### Task 1: Domain Entity에 pendingMinutes 추가

**Files:**
- Modify: `lib/features/fuel/domain/entities/fuel_entity.dart:7-12`

**Step 1: pendingMinutes 필드 추가**

```dart
@freezed
class FuelEntity with _$FuelEntity {
  const factory FuelEntity({
    @Default(0) int currentFuel,
    @Default(0) int totalCharged,
    @Default(0) int totalConsumed,
    @Default(0) int pendingMinutes,
    required DateTime lastUpdatedAt,
  }) = _FuelEntity;
}
```

---

### Task 2: Domain Repository 인터페이스 변경

**Files:**
- Modify: `lib/features/fuel/domain/repositories/fuel_repository.dart:6-10`

**Step 1: chargeFuel 시그니처에 pendingMinutes 추가**

```dart
FuelEntity chargeFuel(
  int amount,
  int pendingMinutes,
  FuelTransactionReason reason, [
  String? referenceId,
]);
```

---

### Task 3: Domain UseCase 변경

**Files:**
- Modify: `lib/features/fuel/domain/usecases/charge_fuel_usecase.dart:9-15`

**Step 1: execute에 pendingMinutes 파라미터 추가**

```dart
FuelEntity execute(
  int amount,
  int pendingMinutes,
  FuelTransactionReason reason, [
  String? referenceId,
]) {
  return _repository.chargeFuel(amount, pendingMinutes, reason, referenceId);
}
```

---

### Task 4: Data Model에 pendingMinutes 추가

**Files:**
- Modify: `lib/features/fuel/data/models/fuel_model.dart:11-16`, `22-28`, `31-37`

**Step 1: FuelModel에 pendingMinutes 필드 추가**

```dart
const factory FuelModel({
  @Default(0) @JsonKey(name: 'current_fuel') int currentFuel,
  @Default(0) @JsonKey(name: 'total_charged') int totalCharged,
  @Default(0) @JsonKey(name: 'total_consumed') int totalConsumed,
  @Default(0) @JsonKey(name: 'pending_minutes') int pendingMinutes,
  @JsonKey(name: 'last_updated_at') required DateTime lastUpdatedAt,
}) = _FuelModel;
```

**Step 2: toEntity 매핑에 pendingMinutes 추가**

```dart
extension FuelModelX on FuelModel {
  FuelEntity toEntity() => FuelEntity(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        pendingMinutes: pendingMinutes,
        lastUpdatedAt: lastUpdatedAt,
      );
}
```

**Step 3: toModel 매핑에 pendingMinutes 추가**

```dart
extension FuelEntityX on FuelEntity {
  FuelModel toModel() => FuelModel(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        pendingMinutes: pendingMinutes,
        lastUpdatedAt: lastUpdatedAt,
      );
}
```

---

### Task 5: Repository 구현체 변경

**Files:**
- Modify: `lib/features/fuel/data/repositories/fuel_repository_impl.dart:22-53`

**Step 1: chargeFuel에 pendingMinutes 파라미터 추가 + amount=0 트랜잭션 생략**

```dart
@override
FuelEntity chargeFuel(
  int amount,
  int pendingMinutes,
  FuelTransactionReason reason, [
  String? referenceId,
]) {
  final current = _localDataSource.getFuel();
  final now = DateTime.now();
  final newFuel = FuelModel(
    currentFuel: current.currentFuel + amount,
    totalCharged: current.totalCharged + amount,
    totalConsumed: current.totalConsumed,
    pendingMinutes: pendingMinutes,
    lastUpdatedAt: now,
  );

  _localDataSource.saveFuel(newFuel).catchError(
    (e) => debugPrint('⚠️ Fuel 저장 실패: $e'),
  );

  // 실제 충전량이 있을 때만 트랜잭션 기록
  if (amount > 0) {
    final transaction = FuelTransactionModel(
      id: now.millisecondsSinceEpoch.toString(),
      type: FuelTransactionType.charge.name,
      amount: amount,
      reason: reason.name,
      referenceId: referenceId,
      balanceAfter: newFuel.currentFuel,
      createdAt: now,
    );
    _localDataSource.addTransaction(transaction).catchError(
      (e) => debugPrint('⚠️ Fuel 트랜잭션 저장 실패: $e'),
    );
  }

  return newFuel.toEntity();
}
```

---

### Task 6: Provider 충전 로직 변경

**Files:**
- Modify: `lib/features/fuel/presentation/providers/fuel_provider.dart:52-64`

**Step 1: chargeFuel에서 pendingMinutes 누적 계산**

```dart
/// 공부 시간으로 연료 충전 (30분 = 1통, 잔여분 누적)
void chargeFuel({required int studyMinutes, String? sessionId}) {
  if (studyMinutes <= 0) return;
  final totalMinutes = state.pendingMinutes + studyMinutes;
  final amount = totalMinutes ~/ 30;
  final newPendingMinutes = totalMinutes % 30;
  final useCase = ref.read(chargeFuelUseCaseProvider);
  state = useCase.execute(
    amount,
    newPendingMinutes,
    FuelTransactionReason.studySession,
    sessionId,
  );
  // 이력도 갱신
  ref.invalidate(fuelTransactionListNotifierProvider);
}
```

---

### Task 7: 코드 생성 및 검증

**Step 1: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: `No issues found!`

---

### Task 8: 커밋

```bash
git add lib/features/fuel/
git commit -m "feat: 연료 충전 잔여 시간 누적 (pendingMinutes) #41"
```

---

## 동작 시나리오

| 세션 | 공부 시간 | 누적 | 충전량 | 잔여 | 총 보유 |
|------|----------|------|--------|------|---------|
| 1 | 15분 | 0+15=15 | 0통 | 15분 | 0통 |
| 2 | 20분 | 15+20=35 | 1통 | 5분 | 1통 |
| 3 | 45분 | 5+45=50 | 1통 | 20분 | 2통 |
| 4 | 60분 | 20+60=80 | 2통 | 20분 | 4통 |

## 마이그레이션 안전성
- `@Default(0)` 적용으로 기존 JSON에 `pending_minutes` 키가 없어도 0으로 초기화
- 기존 사용자 데이터 손실 없음
