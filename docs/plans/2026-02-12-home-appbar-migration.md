# Home Screen TopBar → AppBar Migration

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** HomeScreen의 커스텀 `_buildTopBar()`를 표준 `AppBar`로 교체

**Architecture:** Scaffold의 `appBar` 프로퍼티에 transparent AppBar를 넣고, 기존 SafeArea 수동 처리를 제거. 콘텐츠가 AppBar 뒤로 확장되도록 `extendBodyBehindAppBar: true` 적용.

**Tech Stack:** Flutter Material AppBar

---

### Task 1: _buildTopBar → AppBar 교체

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: Scaffold에 AppBar 추가 및 기존 코드 정리**

변경 사항:
1. `Scaffold`에 `extendBodyBehindAppBar: true` 추가
2. `Scaffold`에 `appBar` 프로퍼티 추가 (transparent, StreakBadge title, 알림 action)
3. body의 `SafeArea` 제거 (AppBar가 safe area를 처리)
4. `_buildTopBar()` 메서드 삭제
5. Column에서 `_buildTopBar()` 호출 제거

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    extendBody: true,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: _streakDays > 0
          ? FadeSlideIn(
              child: StreakBadge(
                days: _streakDays,
                isActive: _isStreakActive,
                showLabel: true,
                size: StreakBadgeSize.large,
              ),
            )
          : null,
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24.w,
          ),
          onPressed: () {
            // TODO: 알림 화면
          },
        ),
        SizedBox(width: 2.w),
      ],
    ),
    body: Stack(
      children: [
        GestureDetector(
          onTap: () {
            _sheetController.animateTo(
              0.22,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              Expanded(child: _buildSpaceshipArea()),
              SizedBox(height: 80.h),
            ],
          ),
        ),
        _buildBottomSheet(),
      ],
    ),
  );
}
```

**Step 2: _buildTopBar 메서드 삭제**

`_buildTopBar()` 메서드 전체 삭제 (line 126-156)

**Step 3: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git commit -m "refactor: HomeScreen _buildTopBar를 AppBar로 교체"
```
