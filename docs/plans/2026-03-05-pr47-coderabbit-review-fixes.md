# PR #47 CodeRabbit 리뷰 수정 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** PR #47 CodeRabbit 리뷰에서 지적된 아키텍처 위반(Settings UseCase 누락, Presentation→Data 직접 참조)과 코드 품질 이슈(토글 레이스 컨디션, setBool 반환값 미확인)를 수정한다.

**Architecture:** Settings feature에 UseCase 레이어를 추가하여 `DataSource → Repository → UseCase → Notifier` 체인을 완성한다. 기존 todo feature의 UseCase 패턴(단일 `execute()` 메서드 + Repository 주입)을 그대로 따른다. Presentation 레이어에서 Data 레이어 import를 제거하고 Domain 인터페이스만 참조하도록 변경한다.

**Tech Stack:** Flutter · Riverpod 2.6 (Generator) · Freezed 2.5 · SharedPreferences

---

## Task 1: GetSettingsUseCase 생성

**Files:**
- Create: `lib/features/settings/domain/usecases/get_settings_usecase.dart`

**Step 1: UseCase 파일 생성**

```dart
import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  AppSettingsEntity execute() {
    return _repository.getSettings();
  }
}
```

> 참고 패턴: `lib/features/todo/domain/usecases/get_todo_list_usecase.dart`
> Repository 인터페이스(`SettingsRepository`)만 의존. Data 레이어 import 없음.

**Step 2: Commit**

```bash
git add lib/features/settings/domain/usecases/get_settings_usecase.dart
git commit -m "feat : GetSettingsUseCase 도메인 유스케이스 생성 #46"
```

---

## Task 2: SetStarTwinkleUseCase 생성

**Files:**
- Create: `lib/features/settings/domain/usecases/set_star_twinkle_usecase.dart`

**Step 1: UseCase 파일 생성**

```dart
import '../repositories/settings_repository.dart';

class SetStarTwinkleUseCase {
  final SettingsRepository _repository;

  SetStarTwinkleUseCase(this._repository);

  Future<void> execute({required bool enabled}) {
    return _repository.setStarTwinkleEnabled(enabled: enabled);
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/settings/domain/usecases/set_star_twinkle_usecase.dart
git commit -m "feat : SetStarTwinkleUseCase 도메인 유스케이스 생성 #46"
```

---

## Task 3: settings_provider.dart 리팩토링 — UseCase 레이어 연결 + 아키텍처 위반 수정

**Files:**
- Modify: `lib/features/settings/presentation/providers/settings_provider.dart`

**이슈:**
- 🟠 Presentation → Data 직접 참조 (import data/datasources, data/repositories)
- 🟠 UseCase 레이어 누락
- 🟡 토글 레이스 컨디션

**Step 1: settings_provider.dart 전체 수정**

DataSource/Repository provider는 별도 파일로 분리하고, presentation 레이어에는 UseCase provider와 Notifier만 남긴다.

수정 후 `settings_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/app_settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/set_star_twinkle_usecase.dart';
import '../../../settings/data/providers/settings_data_providers.dart';

part 'settings_provider.g.dart';

// === UseCase Providers ===

@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}

@riverpod
SetStarTwinkleUseCase setStarTwinkleUseCase(Ref ref) {
  return SetStarTwinkleUseCase(ref.watch(settingsRepositoryProvider));
}

// === Settings 상태 관리 ===

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettingsEntity build() {
    final useCase = ref.read(getSettingsUseCaseProvider);
    return useCase.execute();
  }

  Future<void> toggleStarTwinkle() async {
    final previousState = state;
    final newValue = !state.starTwinkleEnabled;
    state = state.copyWith(starTwinkleEnabled: newValue);

    try {
      final useCase = ref.read(setStarTwinkleUseCaseProvider);
      await useCase.execute(enabled: newValue);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

// === 편의 Provider (SpaceBackground에서 사용) ===

@riverpod
bool starTwinkleEnabled(Ref ref) {
  return ref.watch(
    settingsNotifierProvider.select((s) => s.starTwinkleEnabled),
  );
}
```

**핵심 변경:**
1. `import '../../data/datasources/...'` 제거 → Domain만 import
2. `import '../../data/repositories/...'` 제거 → Domain만 import
3. UseCase provider 2개 추가 (`getSettingsUseCase`, `setStarTwinkleUseCase`)
4. `toggleStarTwinkle()` → 낙관적 업데이트 + 실패 롤백 (todo 패턴 참조)
5. DataSource/Repository provider는 data 레이어 파일로 이동

**Step 2: data 레이어 provider 파일 생성**

Create: `lib/features/settings/data/providers/settings_data_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../repositories/settings_repository_impl.dart';

part 'settings_data_providers.g.dart';

@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  throw StateError(
    'SettingsLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}
```

> DataSource/Repository provider는 data 레이어에 위치하므로 data import가 허용됨.

**Step 3: main.dart import 경로 수정**

Modify: `lib/main.dart`

```dart
// 변경 전:
import 'features/settings/presentation/providers/settings_provider.dart';

// 변경 후:
import 'features/settings/data/providers/settings_data_providers.dart';
```

> `main.dart`는 DI 초기화이므로 data 레이어 접근이 허용됨.
> `settingsLocalDataSourceProvider`가 `settings_data_providers.dart`로 이동했으므로 import 경로 변경 필요.

**Step 4: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `settings_provider.g.dart`와 `settings_data_providers.g.dart` 생성

**Step 5: flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/settings/
git add lib/main.dart
git commit -m "refactor : Settings UseCase 레이어 추가 및 아키텍처 위반 수정 #46"
```

---

## Task 4: SettingsLocalDataSource setBool 반환값 처리

**Files:**
- Modify: `lib/features/settings/data/datasources/settings_local_datasource.dart`

**이슈:** 🟠 `setBool`은 `Future<bool>`을 반환하는데, 저장 실패 시 메모리와 영속 상태가 어긋날 수 있음.

**Step 1: 반환값 확인 로직 추가**

```dart
// 변경 전:
Future<void> setStarTwinkleEnabled({required bool enabled}) async {
  await _prefs.setBool(_keyStarTwinkle, enabled);
}

// 변경 후:
Future<void> setStarTwinkleEnabled({required bool enabled}) async {
  final success = await _prefs.setBool(_keyStarTwinkle, enabled);
  if (!success) {
    throw Exception('SharedPreferences 저장 실패: $_keyStarTwinkle');
  }
}
```

> Notifier의 롤백 로직(Task 3에서 추가)이 이 예외를 catch하여 상태 복원.

**Step 2: Commit**

```bash
git add lib/features/settings/data/datasources/settings_local_datasource.dart
git commit -m "fix : setBool 반환값 확인 및 저장 실패 예외 처리 #46"
```

---

## Task 5: 문서 마크다운 린트 수정

**Files:**
- Modify: `docs/plans/2026-03-03-orbit-timer-design.md`
- Modify: `docs/plans/2026-03-03-orbit-timer-impl.md`

**이슈:** 🟡 코드 블록 언어 식별자 누락, 방향 표기 충돌

**Step 1: orbit-timer-design.md — 코드 펜스에 언어 추가**

3개의 bare ``` 코드 블록에 `text` 언어 식별자 추가:
- Line 31: ```` ``` ```` → ```` ```text ````
- Line 47: ```` ``` ```` → ```` ```text ````
- Line 63: ```` ``` ```` → ```` ```text ```` (또는 적절한 언어)

**Step 2: orbit-timer-impl.md — 방향 표기 통일**

Line 821 근처:
```text
// 변경 전:
**Idle 상태**: 항성 중앙 + 행성 3시 방향(12시 방향) 고정

// 변경 후:
**Idle 상태**: 항성 중앙 + 행성 12시 방향 고정
```

**Step 3: Commit**

```bash
git add docs/plans/2026-03-03-orbit-timer-design.md
git add docs/plans/2026-03-03-orbit-timer-impl.md
git commit -m "docs : 마크다운 코드 펜스 언어 식별자 추가 및 방향 표기 통일 #46"
```

---

## Task 6: 최종 검증

**Step 1: build_runner 재실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 2: 정적 분석**

```bash
flutter analyze
```

Expected: No issues found

**Step 3: 아키텍처 위반 확인**

settings_provider.dart에서 data 레이어 import가 없는지 확인:

```bash
grep -n "import.*data/" lib/features/settings/presentation/providers/settings_provider.dart
```

Expected: 매칭 결과 없음 (data 레이어 직접 참조 0건)

**Step 4: 전체 provider 체인 검증**

최종 의존성 체인:
```
main.dart (DI override)
  └── settingsLocalDataSourceProvider (data/providers/)
       └── settingsRepositoryProvider (data/providers/)
            └── getSettingsUseCaseProvider (presentation/providers/)
            └── setStarTwinkleUseCaseProvider (presentation/providers/)
                 └── SettingsNotifier (presentation/providers/)
                      └── starTwinkleEnabledProvider (presentation/providers/)
                           └── SpaceBackground (UI)
```

---

## 변경 파일 요약

| 파일 | 작업 | Task |
|------|------|------|
| `domain/usecases/get_settings_usecase.dart` | 생성 | 1 |
| `domain/usecases/set_star_twinkle_usecase.dart` | 생성 | 2 |
| `presentation/providers/settings_provider.dart` | 수정 (UseCase 연결, Data import 제거) | 3 |
| `data/providers/settings_data_providers.dart` | 생성 (DataSource/Repository provider 이동) | 3 |
| `main.dart` | 수정 (import 경로) | 3 |
| `data/datasources/settings_local_datasource.dart` | 수정 (setBool 반환값) | 4 |
| `docs/plans/2026-03-03-orbit-timer-design.md` | 수정 (코드 펜스) | 5 |
| `docs/plans/2026-03-03-orbit-timer-impl.md` | 수정 (방향 표기) | 5 |
