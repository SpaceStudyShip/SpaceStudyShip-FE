# 소셜 게스트 로그인 확인 다이얼로그 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** SocialScreen 게스트 뷰의 "로그인하기" 버튼에 경고 다이얼로그를 추가하여 캐시 삭제 전 사용자 확인을 받는다.

**Architecture:** 기존 `AppDialog.confirm`을 활용. 확인 시에만 `signOut()` 호출.

**Tech Stack:** Flutter, AppDialog, Riverpod

---

### Task 1: SocialScreen 게스트 "로그인하기" 버튼에 확인 다이얼로그 추가

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart:56-60`

**Step 1: AppDialog import 추가 및 onPressed 수정**

```dart
// import 추가
import '../../../../core/widgets/dialogs/app_dialog.dart';

// 현재 코드
AppButton(
  text: '로그인하기',
  onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
  width: 200,
),

// 변경 코드
AppButton(
  text: '로그인하기',
  onPressed: () async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '로그인하시겠어요?',
      message: '게스트 모드의 데이터가\n모두 초기화돼요',
      emotion: AppDialogEmotion.warning,
      confirmText: '로그인',
      cancelText: '취소',
    );
    if (confirmed == true) {
      ref.read(authNotifierProvider.notifier).signOut();
    }
  },
  width: 200,
),
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/social/presentation/screens/social_screen.dart
git commit -m "feat: SocialScreen 게스트 로그인 버튼에 확인 다이얼로그 추가"
```

---

## 변경 파일 요약

| # | 파일 | 변경 내용 |
|---|------|----------|
| 1 | `social_screen.dart` | import 1줄 + onPressed 콜백 수정 |

총 1개 파일 수정. 신규 파일 없음.
