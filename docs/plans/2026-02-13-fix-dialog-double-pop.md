# AppDialog.confirm() 더블팝 버그 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `AppDialog.confirm()`에서 확인/취소 버튼 클릭 시 `Navigator.pop()`이 2회 호출되어 GoRouter assertion error가 발생하는 버그를 수정한다.

**Architecture:** `AppDialog`에 `autoClose` 플래그를 추가하여 `_buildButtons`의 자동 pop을 제어. `confirm()`은 `autoClose: false`로 콜백이 직접 pop(값 포함)을 처리.

**Tech Stack:** Flutter, GoRouter, AppDialog

---

## 버그 원인 분석

**에러:** `_AssertionError ('package:go_router/src/delegate.dart': Failed assertion: line 175 pos 7: 'currentConfiguration.isNotEmpty': You have popped the last page off of the stack)`

**원인:** `AppDialog.confirm()`의 더블 pop

1. `_buildButtons`가 `Navigator.of(context).pop()` 호출 → 다이얼로그 닫힘 (Pop #1)
2. `onConfirm`/`onCancel` 콜백이 `Navigator.of(context).pop(true/false)` 호출 → GoRouter 라우트 pop (Pop #2)
3. GoRouter의 마지막 페이지가 pop되면서 assertion 에러 발생

**영향 범위:** `AppDialog.confirm()`을 사용하는 모든 곳 (SocialScreen 게스트 로그인 다이얼로그 등)

---

### Task 1: AppDialog에 autoClose 플래그 추가 및 confirm() 수정

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart`

**Step 1: autoClose 파라미터 추가**

`AppDialog` 생성자에 `autoClose` 필드 추가:

```dart
// 기존 필드 뒤에 추가
/// 버튼 클릭 시 자동으로 다이얼로그를 닫을지 여부
///
/// `true`(기본값): `_buildButtons`가 `Navigator.pop()`을 호출하고 콜백 실행
/// `false`: 콜백이 직접 pop을 처리 (`confirm()`에서 사용)
final bool autoClose;
```

생성자:
```dart
const AppDialog({
  super.key,
  required this.title,
  this.message,
  this.emotion = AppDialogEmotion.none,
  this.confirmText = '확인',
  this.cancelText,
  this.onConfirm,
  this.onCancel,
  this.isDestructive = false,
  this.customContent,
  this.autoClose = true,      // 추가
});
```

**Step 2: _buildButtons에서 autoClose 분기 적용**

3곳 수정 (취소 버튼, 확인 버튼 in Row, 단독 확인 버튼):

```dart
// 취소 버튼 (line ~304-307)
onPressed: () {
  if (autoClose) Navigator.of(context).pop();
  onCancel?.call();
},

// 확인 버튼 in Row (line ~322-325)
onPressed: () {
  if (autoClose) Navigator.of(context).pop();
  onConfirm?.call();
},

// 단독 확인 버튼 (line ~339-342)
onPressed: () {
  if (autoClose) Navigator.of(context).pop();
  onConfirm?.call();
},
```

**Step 3: confirm()에서 autoClose: false 전달**

```dart
// 기존 (line ~171-179)
return AppDialog(
  title: title,
  message: message,
  emotion: emotion,
  confirmText: confirmText,
  cancelText: cancelText,
  isDestructive: isDestructive,
  onConfirm: () => Navigator.of(context).pop(true),
  onCancel: () => Navigator.of(context).pop(false),
);

// 변경
return AppDialog(
  title: title,
  message: message,
  emotion: emotion,
  confirmText: confirmText,
  cancelText: cancelText,
  isDestructive: isDestructive,
  autoClose: false,
  onConfirm: () => Navigator.of(context).pop(true),
  onCancel: () => Navigator.of(context).pop(false),
);
```

**Step 4: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

---

## 변경 파일 요약

| # | 파일 | 변경 내용 |
|---|------|----------|
| 1 | `app_dialog.dart` | `autoClose` 필드 추가 + `_buildButtons` 분기 + `confirm()` 수정 |

총 1개 파일 수정. 신규 파일 없음.

## 영향 분석

- `show()`: 변경 없음 (`autoClose` 기본값 `true`로 기존 동작 유지)
- `confirm()`: `autoClose: false`로 콜백이 pop을 직접 처리 → 더블 pop 해소
- 기존 코드: 하위 호환 (기본값 유지)
