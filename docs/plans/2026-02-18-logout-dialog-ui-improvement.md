# 로그아웃 다이얼로그 UI 개선 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 프로필 로그아웃과 소셜 게스트 로그인 다이얼로그의 UX를 일관되게 통일하고, 불필요한 아이콘을 제거한다.

**Architecture:** 두 화면 모두 이미 `AppDialog.confirm()`을 사용 중이므로 공용 위젯 변경 없이, 호출부의 파라미터만 수정한다. `emotion: AppDialogEmotion.none`으로 변경하여 불필요한 warning 아이콘을 제거하고, `isDestructive: true`를 적용하여 확인 버튼 색상으로 위험 액션임을 표현한다.

**Tech Stack:** Flutter, AppDialog (기존 공용 위젯)

---

## 현재 상태 분석

| 위치 | 파일 | 현재 UX |
|------|------|---------|
| 프로필 > 로그아웃 | `profile_screen.dart:174` | title만, warning 아이콘, message 없음 |
| 소셜 > 게스트 로그인 | `social_screen.dart:60` | title + message, warning 아이콘 |

### 문제점
1. **불필요한 아이콘**: 로그아웃은 경고가 아닌 단순 확인 → warning 아이콘 불필요
2. **UX 불일치**: 프로필은 message 없음, 소셜은 message 있음 → 통일 필요
3. **위험 액션 표현 부족**: 로그아웃은 destructive action이지만 기본 primary 버튼 사용 중

### 개선 방향
- `emotion: AppDialogEmotion.none` — 아이콘 제거
- `isDestructive: true` — 확인 버튼을 빨간색으로 (위험 액션 시각적 표현)
- 프로필 로그아웃에도 안내 message 추가 (일관성)

---

### Task 1: 프로필 로그아웃 다이얼로그 개선

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart:174-180`

**Step 1: AppDialog.confirm() 파라미터 수정**

현재:
```dart
final confirmed = await AppDialog.confirm(
  context: context,
  title: '로그아웃하시겠어요?',
  emotion: AppDialogEmotion.warning,
  confirmText: '로그아웃',
  cancelText: '취소',
);
```

변경:
```dart
final confirmed = await AppDialog.confirm(
  context: context,
  title: '로그아웃하시겠어요?',
  message: '현재 세션이 종료돼요',
  isDestructive: true,
  confirmText: '로그아웃',
  cancelText: '취소',
);
```

변경 사항:
- `emotion: AppDialogEmotion.warning` 제거 (기본값 `none` 적용 → 아이콘 없음)
- `message` 추가 (소셜 다이얼로그와 일관성)
- `isDestructive: true` 추가 (확인 버튼 빨간색)

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

### Task 2: 소셜 게스트 로그인 다이얼로그 개선

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart:60-67`

**Step 1: AppDialog.confirm() 파라미터 수정**

현재:
```dart
final confirmed = await AppDialog.confirm(
  context: context,
  title: '로그인하시겠어요?',
  message: '게스트 모드의 데이터가\n모두 초기화돼요',
  emotion: AppDialogEmotion.warning,
  confirmText: '로그인',
  cancelText: '취소',
);
```

변경:
```dart
final confirmed = await AppDialog.confirm(
  context: context,
  title: '로그인하시겠어요?',
  message: '게스트 모드의 데이터가\n모두 초기화돼요',
  isDestructive: true,
  confirmText: '로그인',
  cancelText: '취소',
);
```

변경 사항:
- `emotion: AppDialogEmotion.warning` 제거 (기본값 `none` 적용 → 아이콘 없음)
- `isDestructive: true` 추가 (확인 버튼 빨간색)
- `message`는 기존 유지 (데이터 초기화 안내는 중요 정보)

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart lib/features/social/presentation/screens/social_screen.dart
git commit -m "fix: 로그아웃 다이얼로그 UX 통일 — 불필요 아이콘 제거, destructive 스타일 적용 #27"
```

---

## 변경 요약

| 항목 | Before | After |
|------|--------|-------|
| 아이콘 | warning (주황 경고) | none (없음) |
| 확인 버튼 | primary (파란색) | destructive (빨간색) |
| 프로필 message | 없음 | '현재 세션이 종료돼요' |
| 소셜 message | 있음 (유지) | 있음 (유지) |
| 공용 위젯 변경 | — | 없음 (호출부만 수정) |
