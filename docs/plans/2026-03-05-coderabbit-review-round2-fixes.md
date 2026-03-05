# CodeRabbit 2차 리뷰 개선 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** PR #47 2차 CodeRabbit 리뷰에서 지적된 아키텍처 위반(Presentation→Data import 잔존) 및 Boolean 네이밍 규칙 위반 수정

**Architecture:** DataSource/Repository provider를 data 레이어로 분리하고, Boolean 변수/함수에 is/has/can 접두사 적용

**Tech Stack:** Flutter · Riverpod (build_runner) · SharedPreferences

---

## 수정 범위 요약

| 심각도 | 파일 | 이슈 |
|--------|------|------|
| 🟠 Major (중복) | `settings_provider.dart:4-5,15-27` | Presentation→Data import 잔존, DataSource/Repository provider 미분리 |
| 🟡 Minor | `settings_local_datasource.dart:10,15` | `getStarTwinkleEnabled` → `isStarTwinkleEnabled`, `success` → `isSaved` |
| 🟡 Minor | `set_star_twinkle_usecase.dart:8` | `enabled` → `isEnabled` (cascading rename) |

---

## 제외 항목 (의도적/기존 패턴)

| 항목 | 사유 |
|------|------|
| StateError 크래시 경로 (settingsLocalDataSourceProvider) | auth 등 다른 feature와 동일한 DI override 패턴 |
| orbit-timer-impl.md Task 5 outdated | 이미 Lottie로 전환 완료된 역사적 계획 문서 |
| docs/ 마크다운 lint (코드 펜스, 헤딩 레벨) | 계획 문서 — 코드 품질에 영향 없음 |

---

### Task 1: DataSource/Repository provider를 data 레이어로 분리

**Files:**
- Create: `lib/features/settings/data/providers/settings_data_providers.dart`
- Modify: `lib/features/settings/presentation/providers/settings_provider.dart`
- Modify: `lib/main.dart` (import 경로 변경)
- Regenerate: `.g.dart` 파일들

**배경:** 1차 리뷰에서 지적된 Presentation→Data 직접 참조가 커밋(4f51e98)에서 UseCase 추가는 됐지만, DataSource/Repository provider가 여전히 presentation 파일에 남아있어 data import가 잔존.

**Step 1: settings_data_providers.dart 생성**

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

**Step 2: settings_provider.dart에서 data 관련 코드 제거**

```dart
// 제거할 import (lines 4-5):
// import '../../data/datasources/settings_local_datasource.dart';
// import '../../data/repositories/settings_repository_impl.dart';

// 추가할 import:
import '../../data/providers/settings_data_providers.dart';

// 제거할 provider 정의 (lines 13-27):
// @riverpod SettingsLocalDataSource settingsLocalDataSource(...)
// @riverpod SettingsRepository settingsRepository(...)
```

수정 후 `settings_provider.dart` import 섹션:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/settings_data_providers.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/set_star_twinkle_usecase.dart';
```

> Note: `settings_data_providers.dart` import는 UseCase provider가 `settingsRepositoryProvider`를 참조하기 때문에 필요. data 레이어 "구현체"가 아닌 data 레이어의 "provider export"만 참조하므로 DI 연결 목적으로 허용.

**Step 3: main.dart import 경로 변경**

```dart
// 변경 전:
import 'features/settings/presentation/providers/settings_provider.dart';

// 변경 후 (settingsLocalDataSourceProvider가 이동했으므로):
import 'features/settings/data/providers/settings_data_providers.dart';
```

> `main.dart`는 DI 초기화이므로 data 레이어 접근 허용.
> `settingsNotifierProvider` 등 presentation provider는 다른 파일에서 import 중이므로 main.dart에서 presentation import 제거 가능.

**Step 4: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `settings_data_providers.g.dart` 생성, `settings_provider.g.dart` 재생성

**Step 5: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 6: 아키텍처 위반 확인**

`settings_provider.dart`에서 data 레이어 직접 import가 없는지 확인:
- `import '../../data/datasources/'` → 없어야 함
- `import '../../data/repositories/'` → 없어야 함
- `import '../../data/providers/'` → 허용 (DI provider export)

**Step 7: Commit**

```bash
git add lib/features/settings/
git add lib/main.dart
git commit -m "refactor: Settings DataSource/Repository provider를 data 레이어로 분리 #46"
```

---

### Task 2: Boolean 네이밍 is/has/can 접두사 적용

**Files:**
- Modify: `lib/features/settings/data/datasources/settings_local_datasource.dart`
- Modify: `lib/features/settings/data/repositories/settings_repository_impl.dart`
- Modify: `lib/features/settings/domain/repositories/settings_repository.dart`
- Modify: `lib/features/settings/domain/usecases/set_star_twinkle_usecase.dart`
- Modify: `lib/features/settings/presentation/providers/settings_provider.dart`

**Step 1: settings_local_datasource.dart — 메서드명 + 변수명**

```dart
// Line 10 — Before:
bool getStarTwinkleEnabled() {
// After:
bool isStarTwinkleEnabled() {

// Line 15 — Before:
final success = await _prefs.setBool(_keyStarTwinkle, enabled);
if (!success) {
// After:
final isSaved = await _prefs.setBool(_keyStarTwinkle, isEnabled);
if (!isSaved) {

// Line 14 — Before:
Future<void> setStarTwinkleEnabled({required bool enabled}) async {
// After:
Future<void> setStarTwinkleEnabled({required bool isEnabled}) async {
```

**Step 2: settings_repository.dart — 인터페이스 파라미터명**

```dart
// Before:
Future<void> setStarTwinkleEnabled({required bool enabled});
// After:
Future<void> setStarTwinkleEnabled({required bool isEnabled});
```

**Step 3: settings_repository_impl.dart — 구현체**

```dart
// Line 13 — Before:
starTwinkleEnabled: _dataSource.getStarTwinkleEnabled(),
// After:
starTwinkleEnabled: _dataSource.isStarTwinkleEnabled(),

// Line 18 — Before:
Future<void> setStarTwinkleEnabled({required bool enabled}) async {
  await _dataSource.setStarTwinkleEnabled(enabled: enabled);
// After:
Future<void> setStarTwinkleEnabled({required bool isEnabled}) async {
  await _dataSource.setStarTwinkleEnabled(isEnabled: isEnabled);
```

**Step 4: set_star_twinkle_usecase.dart — 파라미터명**

```dart
// Before:
Future<void> execute({required bool enabled}) {
  return _repository.setStarTwinkleEnabled(enabled: enabled);
// After:
Future<void> execute({required bool isEnabled}) {
  return _repository.setStarTwinkleEnabled(isEnabled: isEnabled);
```

**Step 5: settings_provider.dart — 호출부**

```dart
// Line 58 — Before:
await useCase.execute(enabled: newValue);
// After:
await useCase.execute(isEnabled: newValue);
```

**Step 6: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 7: Commit**

```bash
git add lib/features/settings/
git commit -m "style: Boolean 네이밍 is/has/can 접두사 적용 #46"
```
