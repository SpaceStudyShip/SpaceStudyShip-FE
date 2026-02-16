# 바텀시트 snap 드래그 UX 개선

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoSelectBottomSheet가 처음 열릴 때 화면의 40% 높이로 올라오고, 드래그하면 유튜브 댓글창처럼 90%까지 확장되며 snap 포인트로 부드럽게 전환되도록 개선한다.

**Architecture:** 현재 DraggableScrollableSheet는 이미 적용되어 있으나 `snap` 동작이 없어 드래그 시 어중간한 위치에 멈출 수 있다. `snap: true`와 `snapSizes`를 추가하여 40% ↔ 90% 사이를 부드럽게 전환하도록 한다.

**Tech Stack:** Flutter, DraggableScrollableSheet, snap

---

## 현재 상태 분석

`todo_select_bottom_sheet.dart`에 DraggableScrollableSheet가 이미 적용되어 있다:
- `initialChildSize: 0.4` (40%에서 시작)
- `minChildSize: 0.3` (30%까지 줄일 수 있음)
- `maxChildSize: 0.9` (90%까지 확장 가능)
- `expand: false`
- **문제: `snap`이 없어서 드래그 후 어중간한 위치에 멈춤**

## Task 1: DraggableScrollableSheet에 snap 동작 추가

**Files:**
- Modify: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart:20-24`

**Step 1: snap 속성 추가**

```dart
return DraggableScrollableSheet(
  initialChildSize: 0.4,
  minChildSize: 0.3,
  maxChildSize: 0.9,
  snap: true,
  snapSizes: const [0.4, 0.9],
  expand: false,
  builder: (context, scrollController) {
```

변경점:
- `snap: true` 추가 → 드래그 놓으면 가장 가까운 snap 포인트로 이동
- `snapSizes: const [0.4, 0.9]` 추가 → 40%(초기)와 90%(확장) 두 포인트

**Step 2: flutter analyze 검증**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "feat: TodoSelectBottomSheet snap 드래그 UX 추가 #16"
```

---

## Task 2: 최종 검증

수동 테스트 체크리스트:
- [ ] 타이머 시작 → 바텀시트 40% 높이로 열림
- [ ] 바텀시트 위로 드래그 → 90%로 snap 확장
- [ ] 바텀시트 아래로 드래그 → 40%로 snap 축소
- [ ] 40% 이하로 드래그 → dismiss (닫힘)
- [ ] dismiss 시 타이머 시작 안 됨 (기존 동작 유지)
- [ ] "연동 없이 시작" 탭 → 타이머 시작 (기존 동작 유지)
- [ ] 할일 선택 탭 → 타이머 시작 + 연동 (기존 동작 유지)
