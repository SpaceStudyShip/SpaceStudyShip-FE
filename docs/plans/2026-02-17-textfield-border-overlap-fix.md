# TextField 테두리 중첩 수정

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** AppTextField의 배경색이 바텀시트 배경과 동일해서 생기는 테두리 중첩 제거

**Architecture:** AppTextField의 enabled 배경색을 `spaceSurface` → `spaceBackground`로 변경하여 필드가 인셋(움푹 들어간) 느낌을 준다.

**Tech Stack:** Flutter

---

## 문제

```
바텀시트 Container (spaceSurface: #1A1F3A)
  └─ AppTextField AnimatedContainer (spaceSurface: #1A1F3A + spaceDivider 테두리)
       └─ TextField (InputBorder.none)
```

배경색이 동일 → 테두리선만 보이면서 중첩/어색한 시각 효과

## 수정

```
바텀시트 Container (spaceSurface: #1A1F3A)
  └─ AppTextField AnimatedContainer (spaceBackground: #0A0E27 + spaceDivider 테두리)
       └─ TextField (InputBorder.none)
```

더 어두운 배경 → 필드 영역이 자연스럽게 구분됨

---

### Task 1: AppTextField 배경색 변경

**Files:**
- Modify: `lib/core/widgets/inputs/app_text_field.dart:277-278`

**Step 1: enabled 배경색을 spaceBackground로 변경**

```dart
// Before
color: widget.enabled
    ? AppColors.spaceSurface
    : AppColors.spaceBackground,

// After
color: AppColors.spaceBackground,
```

**Step 2: analyze 확인**

Run: `flutter analyze lib/core/widgets/inputs/app_text_field.dart`

**Step 3: Commit**

```bash
git add lib/core/widgets/inputs/app_text_field.dart
git commit -m "fix: AppTextField 배경색 변경으로 테두리 중첩 제거"
```

## 영향 범위

AppTextField 사용 파일 (모두 spaceSurface 바텀시트 배경):
- `todo_add_bottom_sheet.dart` ✅ 개선됨
- `category_add_bottom_sheet.dart` ✅ 개선됨
- `test_widget_page.dart` (테스트 페이지, 무관)
