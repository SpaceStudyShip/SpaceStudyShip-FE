# CodeRabbit PR #42 리뷰 수정 구현 계획

**Goal:** PR #42 CodeRabbit 리뷰에서 지적된 Major 3건, Minor 9건을 수정하여 머지 가능 상태로 만든다.

**Architecture:** 기존 Clean Architecture 레이어 구조 유지. 런타임 안전성 > 코드 품질 > 문서 순서로 수정. Riverpod 생명주기 정합성 확보.

**Tech Stack:** Flutter/Dart, Riverpod (Generator), Freezed, SharedPreferences

---

## 이슈 요약

| #   | 심각도   | 파일                                | 이슈                                                     |
| --- | -------- | ----------------------------------- | -------------------------------------------------------- |
| 1   | 🟠 Major | `exploration_provider.dart`         | `canUnlockPlanet` — 존재하지 않는 planetId에 `true` 반환 |
| 2   | 🟠 Major | `explore_screen.dart`               | `planets[targetIndex - 1]` — RangeError 잠재적 충돌      |
| 3   | 🟠 Major | `fuel_provider.dart`                | keepAlive 노티파이어가 AutoDispose 프로바이더 의존       |
| 4   | 🟡 Minor | `explore_screen.dart`               | `void async` 안티패턴 — 예외 무음 처리                   |
| 5   | 🟡 Minor | `explore_screen.dart`               | `isDestructive: true` 로그인 다이얼로그에 잘못 적용      |
| 6   | 🟡 Minor | `exploration_local_datasource.dart` | `_prefs.remove()` Future 미대기                          |
| 7   | 🟡 Minor | `fuel_exceptions.dart`              | `required` 필드명이 Dart 키워드와 혼동                   |
| 8   | 🟡 Minor | `fuel_transaction_model.dart`       | `DateTime.parse()` FormatException 미처리                |
| 9   | 🟡 Minor | 계획 문서 4개                       | `double` → `int` 타입 불일치 + Markdown lint             |

---

## Task 1: `canUnlockPlanet` 방어 코드 추가 (Major)

**Files:**

- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart:59-64`

**Step 1: 수정 — indexWhere -1 케이스 분리**

```dart
// 현재 코드 (버그)
bool canUnlockPlanet(String planetId) {
  final planets = state;
  final targetIndex = planets.indexWhere((p) => p.id == planetId);
  if (targetIndex <= 0) return true;  // -1(미발견)도 true 반환!
  return planets[targetIndex - 1].isUnlocked;
}
```

→ 수정:

```dart
bool canUnlockPlanet(String planetId) {
  final planets = state;
  final targetIndex = planets.indexWhere((p) => p.id == planetId);
  if (targetIndex < 0) return false;  // 존재하지 않는 행성
  if (targetIndex == 0) return true;  // 첫 번째 행성은 항상 해금 가능
  return planets[targetIndex - 1].isUnlocked;
}
```

**Step 2: `explore_screen.dart` RangeError 방어 코드 추가 (Major)**

`lib/features/explore/presentation/screens/explore_screen.dart:226-232` 수정:

```dart
// 현재 코드 (RangeError 가능)
if (!canUnlock) {
  final planets = ref.read(explorationNotifierProvider);
  final targetIndex = planets.indexWhere((p) => p.id == planet.id);
  final prevPlanet = planets[targetIndex - 1];  // targetIndex가 0이나 -1이면 크래시!
  AppSnackBar.info(context, '${prevPlanet.name}을(를) 먼저 해금해야 합니다!');
  return;
}
```

→ 수정:

```dart
if (!canUnlock) {
  final planets = ref.read(explorationNotifierProvider);
  final targetIndex = planets.indexWhere((p) => p.id == planet.id);
  if (targetIndex > 0) {
    final prevPlanet = planets[targetIndex - 1];
    AppSnackBar.info(context, '${prevPlanet.name}을(를) 먼저 해금해야 합니다!');
  } else {
    AppSnackBar.info(context, '이 행성은 해금할 수 없습니다');
  }
  return;
}
```

**Step 3: `flutter analyze` 실행하여 오류 없는지 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/exploration/presentation/providers/exploration_provider.dart lib/features/explore/presentation/screens/explore_screen.dart
git commit -m "fix: canUnlockPlanet 방어 코드 추가 — 미존재 행성 및 RangeError 방지"
```

---

## Task 2: Riverpod keepAlive 생명주기 정합성 확보 (Major)

**Files:**

- Modify: `lib/features/fuel/presentation/providers/fuel_provider.dart:14-26`
- Regenerate: `lib/features/fuel/presentation/providers/fuel_provider.g.dart`

**Step 1: `fuelLocalDataSource`와 `fuelRepository` 프로바이더에 keepAlive 추가**

```dart
// 현재 코드
@riverpod
FuelLocalDataSource fuelLocalDataSource(Ref ref) { ... }

@riverpod
FuelRepository fuelRepository(Ref ref) { ... }
```

→ 수정:

```dart
@Riverpod(keepAlive: true)
FuelLocalDataSource fuelLocalDataSource(Ref ref) { ... }

@Riverpod(keepAlive: true)
FuelRepository fuelRepository(Ref ref) { ... }
```

**Step 2: build_runner로 코드 재생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 정상 완료, `fuel_provider.g.dart` 재생성

**Step 3: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/fuel/presentation/providers/fuel_provider.dart lib/features/fuel/presentation/providers/fuel_provider.g.dart
git commit -m "fix: fuel 프로바이더 keepAlive 생명주기 정합성 확보"
```

---

## Task 3: `explore_screen.dart` void async + isDestructive 수정 (Minor)

**Files:**

- Modify: `lib/features/explore/presentation/screens/explore_screen.dart:251-263`

**Step 1: `_showLoginPrompt` 시그니처 및 isDestructive 수정**

```dart
// 현재 코드
void _showLoginPrompt(BuildContext context, WidgetRef ref) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '로그인하시겠어요?',
    message: '게스트 모드의 데이터가\n모두 초기화돼요',
    isDestructive: true,
    confirmText: '로그인',
    cancelText: '취소',
  );
  if (confirmed == true) {
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}
```

→ 수정:

```dart
Future<void> _showLoginPrompt(BuildContext context, WidgetRef ref) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '로그인하시겠어요?',
    message: '게스트 모드의 데이터가\n모두 초기화돼요',
    confirmText: '로그인',
    cancelText: '취소',
  );
  if (confirmed == true) {
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}
```

변경점:

- `void` → `Future<void>` (async 안티패턴 해소)
- `isDestructive: true` 제거 (로그인은 파괴적 작업이 아님, 기본값 false 사용)

**Step 2: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/explore/presentation/screens/explore_screen.dart
git commit -m "fix: 로그인 다이얼로그 isDestructive 제거 및 void async 안티패턴 수정"
```

---

## Task 4: `exploration_local_datasource` unawaited Future 명시 (Minor)

**Files:**

- Modify: `lib/features/exploration/data/datasources/exploration_local_datasource.dart:67-71`

**Step 1: import 추가 및 unawaited 명시**

파일 상단 import 추가:

```dart
import 'dart:async';
```

catch 블록 수정:

```dart
// 현재 코드
} catch (e) {
  debugPrint('⚠️ Exploration 상태 파싱 실패, 초기화합니다: $e');
  _prefs.remove(_stateKey);
  return {};
}
```

→ 수정:

```dart
} catch (e) {
  debugPrint('⚠️ Exploration 상태 파싱 실패, 초기화합니다: $e');
  unawaited(_prefs.remove(_stateKey));
  return {};
}
```

**Step 2: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/exploration/data/datasources/exploration_local_datasource.dart
git commit -m "fix: exploration datasource unawaited Future 명시적 처리"
```

---

## Task 5: `InsufficientFuelException` 필드 이름 개선 (Minor)

**Files:**

- Modify: `lib/features/fuel/domain/exceptions/fuel_exceptions.dart`
- Modify: 이 예외를 사용하는 모든 파일 (catch/throw 사이트)

**Step 1: 예외 필드명 변경 — `required` → `requiredAmount`**

```dart
// 현재 코드
class InsufficientFuelException implements Exception {
  final int required;
  final int available;

  InsufficientFuelException({required this.required, required this.available});

  @override
  String toString() => '연료가 부족합니다 (필요: $required통, 보유: $available통)';
}
```

→ 수정:

```dart
class InsufficientFuelException implements Exception {
  final int requiredAmount;
  final int available;

  InsufficientFuelException({required this.requiredAmount, required this.available});

  @override
  String toString() => '연료가 부족합니다 (필요: $requiredAmount통, 보유: $available통)';
}
```

**Step 2: 이 예외를 throw/catch하는 코드에서 필드 참조 업데이트**

`grep -r 'InsufficientFuelException' lib/` 로 사용처 확인 후 `required:` → `requiredAmount:` 변경.

예상 파일: `fuel_repository_impl.dart` (throw 사이트)

**Step 3: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/fuel/domain/exceptions/fuel_exceptions.dart lib/features/fuel/data/repositories/fuel_repository_impl.dart
git commit -m "refactor: InsufficientFuelException 필드명 required → requiredAmount"
```

---

## Task 6: `FuelTransactionModel` DateTime 파싱 안전성 확보 (Minor)

**Files:**

- Modify: `lib/features/fuel/data/models/fuel_transaction_model.dart`
- Regenerate: `lib/features/fuel/data/models/fuel_transaction_model.g.dart`

**Step 1: SafeDateTimeConverter 생성 및 적용**

`fuel_transaction_model.dart`에 JsonConverter 추가:

```dart
class SafeDateTimeConverter implements JsonConverter<DateTime, String> {
  const SafeDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.tryParse(json) ?? DateTime.now();
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
```

`createdAt` 필드에 어노테이션 추가:

```dart
@SafeDateTimeConverter()
@JsonKey(name: 'created_at')
required DateTime createdAt,
```

**Step 2: build_runner로 코드 재생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 정상 완료

**Step 3: `flutter analyze` 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/fuel/data/models/fuel_transaction_model.dart lib/features/fuel/data/models/fuel_transaction_model.g.dart
git commit -m "fix: FuelTransactionModel DateTime 파싱 안전성 확보"
```

---

## Task 7: 계획 문서 double → int 타입 통일 + Markdown lint 수정 (Minor)

**Files:**

- Modify: `docs/plans/2026-02-20-fuel-system-design.md`
- Modify: `docs/plans/2026-02-20-fuel-system-implementation.md`
- Modify: `docs/plans/2026-02-20-guest-explore-login-prompt.md`

**Step 1: 계획 문서 전체에서 연료 타입 double → int 변경**

변경 대상:

- `@Default(0.0) double` → `@Default(0) int`
- `required double amount` → `required int amount`
- `required double balanceAfter` → `required int balanceAfter`
- `chargeFuel(double amount` → `chargeFuel(int amount`
- `consumeFuel(double amount` → `consumeFuel(int amount`
- `canConsume(double amount)` → `canConsume(int amount)`
- `final double required` → `final int requiredAmount`
- `final double available` → `final int available`

**Step 2: Markdown lint 수정**

- `fuel-system-design.md`: 언어 미지정 코드 블록에 `text 또는 `dart 추가, 표 앞뒤 빈 줄 추가
- `guest-explore-login-prompt.md`: Before 코드 블록에 ```dart 추가, `isDestructive: true`→ 제거,`void \_showLoginPrompt`→`Future<void> \_showLoginPrompt`

**Step 3: 커밋**

```bash
git add docs/plans/
git commit -m "docs: 계획 문서 double→int 타입 통일 및 Markdown lint 수정"
```

---

## 최종 검증

**Step 1: 전체 분석 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 전체 변경사항 확인**

Run: `git diff --stat HEAD~7` (커밋 수에 따라 조정)

**Step 3: force-push로 PR 업데이트**

Run: `git push --force-with-lease origin 20260220_#41_앱_전체_연료_Fuel_시스템_구축`
