# 하드코딩된 Spacing/Radius 상수 치환 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `spacing_and_radius.dart` 상수와 매칭되는 하드코딩된 spacing/radius 값을 상수로 교체

**Architecture:** 단순 치환 작업. 매칭 상수가 존재하는 값만 교체하고, 존재하지 않는 값(2, 6, 10, 14, 20 radius 등)은 의도적 하드코딩으로 유지.

**Tech Stack:** Flutter, spacing_and_radius.dart (AppSpacing, AppPadding, AppRadius)

---

## 탐색 결과 요약

전체 `lib/` 디렉토리 탐색 결과, **2개 파일**에서 매칭 상수가 있는 하드코딩 값 발견:

- `lib/main.dart` — SizedBox 2건
- `lib/core/theme/app_theme.dart` — BorderRadius 7건

나머지 파일은 `EdgeInsets.only`, `EdgeInsets.fromLTRB`, 비표준 조합(`h20+v12` 등), 또는 매칭 상수 없는 값(2.r, 20.r 등)으로 하드코딩 허용 범위.

---

### Task 1: main.dart — SizedBox 하드코딩 치환

**Files:**
- Modify: `lib/main.dart:217, 230`

**⚠️ 참고:** `const SizedBox(width: 8)` → `SizedBox(width: AppSpacing.s8)`로 변경 시 `const` 제거 필요 (AppSpacing.s8은 getter)

**Step 1: import 추가**

`lib/main.dart` 상단에 import 추가:
```dart
import 'core/constants/spacing_and_radius.dart';
```

**Step 2: 치환 적용**

| Line | Before | After |
|------|--------|-------|
| 217 | `const SizedBox(width: 8)` | `SizedBox(width: AppSpacing.s8)` |
| 230 | `const SizedBox(height: 16)` | `SizedBox(height: AppSpacing.s16)` |

**Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: main.dart SizedBox 하드코딩을 AppSpacing 상수로 치환"
```

---

### Task 2: app_theme.dart — BorderRadius 하드코딩 치환

**Files:**
- Modify: `lib/core/theme/app_theme.dart:49, 57, 121, 125, 129, 133, 161`

**⚠️ 참고:** 테마 파일은 현재 `BorderRadius.circular(12)` (plain int, no `.r`). AppRadius 상수는 `.r` 사용. 치환 시 반응형 스케일링 적용됨. ScreenUtilInit 내에서 테마가 빌드되므로 정상 동작.

**Step 1: import 추가**

`lib/core/theme/app_theme.dart` 상단에 import 추가:
```dart
import '../constants/spacing_and_radius.dart';
```

**Step 2: 치환 적용**

| Line | Before | After | 비고 |
|------|--------|-------|------|
| 49 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.card` | 카드 테마이므로 card 사용 |
| 57 | `borderRadius: BorderRadius.circular(16)` | `borderRadius: AppRadius.xlarge` | 16px |
| 70 | `BorderRadius.vertical(top: Radius.circular(20))` | 유지 (하드코딩) | 20은 AppRadius에 없음 |
| 121 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.large` | input border |
| 125 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.large` | enabled border |
| 129 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.large` | focused border |
| 133 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.large` | error border |
| 161 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppRadius.snackbar` | 스낵바 테마이므로 snackbar 사용 |

**Step 3: const 키워드 처리**

`AppRadius` getter는 `const`가 아니므로, 관련된 상위 위젯에서 `const` 제거 필요:
- Line 69: `const RoundedRectangleBorder(...)` 는 line 70이 하드코딩 유지이므로 변경 없음

카드테마(49), 다이얼로그(57), 입력필드(121-133), 스낵바(161)의 상위 위젯이 `const`인지 확인하고 제거.

**Step 4: 빌드 확인**

Run: `flutter analyze`
Expected: No issues

**Step 5: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "refactor: app_theme.dart BorderRadius 하드코딩을 AppRadius 상수로 치환"
```

---

## 최종 검증

Run: `flutter analyze`
Expected: No issues

총 변경: **2개 파일, 9건 치환**
