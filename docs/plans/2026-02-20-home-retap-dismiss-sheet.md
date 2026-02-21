# 홈 탭 재탭 시 바텀시트 닫기 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 바텀 네비게이션에서 홈 탭을 다시 누르면 열려 있는 DraggableScrollableSheet를 접는다.

**Architecture:** Riverpod StateProvider로 "홈 탭 재탭" 이벤트를 전달. MainShell에서 이벤트 발행 → HomeScreen에서 ref.listen으로 수신하여 시트 접기.

**Tech Stack:** Flutter · Riverpod · go_router StatefulShellRoute

---

## 현재 구조 요약

| 파일 | 역할 |
|------|------|
| `lib/routes/main_shell.dart` | 바텀 네비 (StatelessWidget), `_onTap` → `goBranch()` |
| `lib/features/home/presentation/screens/home_screen.dart` | `DraggableScrollableSheet` (0.30~0.85 snap), `_isSheetExpanded` |

**현재 재탭 동작**: `_onTap`에서 `index == navigationShell.currentIndex`일 때 `initialLocation: true`로 스택 pop — 바텀시트에는 영향 없음.

---

## Task 1: 홈 재탭 이벤트 Provider 생성

**Files:**
- Create: `lib/routes/navigation_providers.dart`

**Step 1: Provider 파일 생성**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 탭 재탭 이벤트 카운터
///
/// MainShell에서 홈 탭 재탭 시 increment → HomeScreen에서 listen하여 시트 접기.
final homeReTapProvider = StateProvider<int>((ref) => 0);
```

**Step 2: 확인**

Run: `flutter analyze`
Expected: No issues

---

## Task 2: MainShell을 ConsumerWidget으로 변환 + 재탭 시 이벤트 발행

**Files:**
- Modify: `lib/routes/main_shell.dart`

**Step 1: import 추가 및 클래스 변환**

변경 사항:
1. `import 'package:flutter_riverpod/flutter_riverpod.dart';` 추가
2. `import 'navigation_providers.dart';` 추가
3. `StatelessWidget` → `ConsumerWidget`
4. `build(BuildContext context)` → `build(BuildContext context, WidgetRef ref)`

**Step 2: `_onTap`에서 홈 탭 재탭 시 Provider increment**

`_onTap` 메서드를 build 내부 로컬 함수로 변경 (ref 접근을 위해):

```dart
void onTap(int index) {
  // 홈 탭 재탭: 바텀시트 닫기 이벤트 발행
  if (index == 0 && index == navigationShell.currentIndex) {
    ref.read(homeReTapProvider.notifier).state++;
  }
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
```

**Step 3: 확인**

Run: `flutter analyze`
Expected: No issues

---

## Task 3: HomeScreen에서 이벤트 수신 → 시트 접기

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: import 추가**

```dart
import '../../../../routes/navigation_providers.dart';
```

**Step 2: build() 내부에 ref.listen 추가**

build 메서드 초반부에 추가:

```dart
ref.listen(homeReTapProvider, (prev, next) {
  if (_isSheetExpanded) {
    _sheetController.animateTo(
      0.30,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
});
```

**Step 3: 확인**

Run: `flutter analyze`
Expected: No issues

---

## Task 4: 수동 검증 + 커밋

**Step 1: 동작 확인 체크리스트**

- [ ] 홈 탭에서 시트 펼침 (0.85) → 홈 탭 재탭 → 시트 접힘 (0.30)
- [ ] 홈 탭에서 시트 접힌 상태 → 홈 탭 재탭 → 변화 없음 (이미 접혀있음)
- [ ] 다른 탭 → 홈 탭 → 시트 영향 없음 (재탭이 아닌 탭 전환)
- [ ] 시트 접힐 때 캘린더 주간 포맷 리셋 정상 동작 (기존 `_onSheetChanged` 리스너)

**Step 2: 커밋**

```bash
git add lib/routes/navigation_providers.dart lib/routes/main_shell.dart lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat: 홈 탭 재탭 시 바텀시트 자동 닫기"
```

---

## 파일 변경 요약

| 파일 | 변경 | 라인 수 (예상) |
|------|------|-------------|
| `lib/routes/navigation_providers.dart` | **신규** — StateProvider 1개 | ~5줄 |
| `lib/routes/main_shell.dart` | ConsumerWidget 변환 + onTap 수정 | ~5줄 변경 |
| `lib/features/home/presentation/screens/home_screen.dart` | ref.listen 추가 | ~8줄 추가 |
| **총** | 3개 파일 | ~18줄 |
