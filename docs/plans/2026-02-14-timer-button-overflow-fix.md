# 타이머 컨트롤 버튼 오버플로우 수정

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머 실행/일시정지 상태에서 버튼 2개가 화면 너비를 초과하여 발생하는 RIGHT OVERFLOWED BY 342 PIXELS 버그를 수정한다.

**Architecture:** `_buildControls` 메서드의 Row 내부 AppButton 2개가 각각 기본 너비 353.w를 사용하여 총 722.w가 필요하지만, 화면 너비는 390.w뿐이다. Row 안에서 `Expanded`로 감싸 균등 분배하면 해결된다.

**Tech Stack:** Flutter, flutter_screenutil

---

## 원인 분석

| 구성 요소 | 너비 | 비고 |
|-----------|------|------|
| AppButton "일시정지" | 353.w | 기본값 (app_button.dart:182) |
| SizedBox 간격 | 16.w | AppSpacing.s16 |
| AppButton "정지" | 353.w | 기본값 |
| **합계** | **722.w** | 화면 390.w 초과 → 오버플로우 |

## Task 1: 타이머 컨트롤 버튼 오버플로우 수정

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:207-232`

**Step 1: _buildControls 메서드 수정**

`Row` 안의 `AppButton`들을 `Expanded`로 감싸고, `width: double.infinity`를 명시하여 균등 분배한다.

```dart
  Widget _buildControls(bool isIdle, bool isRunning, bool isPaused) {
    if (isIdle) {
      return AppButton(text: '시작하기', onPressed: _onStart);
    }

    return Row(
      children: [
        if (isRunning)
          Expanded(
            child: AppButton(
              text: '일시정지',
              onPressed: () => ref.read(timerNotifierProvider.notifier).pause(),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textSecondary,
              borderColor: AppColors.spaceDivider,
              width: double.infinity,
            ),
          ),
        if (isPaused)
          Expanded(
            child: AppButton(
              text: '계속하기',
              onPressed: () => ref.read(timerNotifierProvider.notifier).resume(),
              width: double.infinity,
            ),
          ),
        SizedBox(width: AppSpacing.s16),
        Expanded(
          child: AppButton(
            text: '정지',
            onPressed: () => ref.read(timerNotifierProvider.notifier).stop(),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.error,
            borderColor: AppColors.error.withValues(alpha: 0.5),
            width: double.infinity,
          ),
        ),
      ],
    );
  }
```

**Step 2: 앱 실행하여 수정 확인**

```bash
flutter run
```

수동 확인:
- [ ] 타이머 시작 → 일시정지/정지 버튼 2개가 화면 내에 균등 배치
- [ ] 일시정지 → 계속하기/정지 버튼 2개가 화면 내에 균등 배치
- [ ] 대기 상태 → 시작하기 버튼 1개 정상 표시
- [ ] 오버플로우 경고 없음

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "fix: 타이머 컨트롤 버튼 오버플로우 수정 #16"
```
