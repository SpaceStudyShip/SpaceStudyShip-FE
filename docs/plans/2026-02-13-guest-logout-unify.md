# 게스트 로그아웃 통일 및 캐시 정리 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 게스트 모드의 "로그인하기"를 "로그아웃"으로 통일하고, 게스트 로그아웃 시 SharedPreferences 캐시를 완전히 정리한다.

**Architecture:** ProfileScreen의 게스트 분기를 제거하여 로그인/게스트 모두 "로그아웃" 하나로 통일. `signOut()`에서 게스트 관련 SharedPreferences 키 전체 정리. SocialScreen의 "로그인하기" 버튼도 동일한 `signOut()` 경로를 타도록 유지. GoRouter redirect가 `state=null` 감지하면 자동으로 `/login`으로 이동하므로 수동 `context.go` 불필요.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, GoRouter

---

### Task 1: signOut()에서 게스트 캐시 완전 정리

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:286-294`

**Step 1: signOut() 게스트 분기 수정**

현재 `signOut()`의 게스트 분기(286-294줄)를 수정하여 `is_guest`만 지우는 게 아니라 `has_seen_onboarding`도 함께 정리:

```dart
// 게스트 모드 → SharedPreferences 정리
final currentUser = state.valueOrNull;
if (currentUser?.isGuest == true) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('is_guest');
  await prefs.remove('has_seen_onboarding');
  state = const AsyncValue.data(null);
  return;
}
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix: 게스트 signOut 시 has_seen_onboarding 캐시도 정리"
```

---

### Task 2: ProfileScreen 로그아웃 버튼 통일

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart:176-196`

**Step 1: 게스트/로그인 분기 제거, "로그아웃"으로 통일**

`_buildMenuList()`에서 `if (isGuest) ... else ...` 분기를 제거하고 하나의 로그아웃 메뉴로 통일. `isGuest` 변수와 관련 분기 전체 제거:

```dart
Widget _buildMenuList(
  BuildContext context,
  WidgetRef ref,
  AuthResultEntity? user,
) {
  return Column(
    children: [
      _buildMenuItem(
        icon: Icons.bar_chart_outlined,
        title: '통계',
        onTap: () => context.push(RoutePaths.statistics),
      ),
      _buildMenuItem(
        icon: Icons.emoji_events_outlined,
        title: '배지 컬렉션',
        onTap: () => context.push(RoutePaths.badges),
      ),
      _buildMenuItem(
        icon: Icons.rocket_launch_outlined,
        title: '우주선 컬렉션',
        onTap: () => context.push(RoutePaths.spaceships),
      ),
      _buildMenuItem(
        icon: Icons.info_outline_rounded,
        title: '앱 정보',
        onTap: () => context.push(RoutePaths.about),
      ),
      SizedBox(height: AppSpacing.s16),
      _buildMenuItem(
        icon: Icons.logout_rounded,
        title: '로그아웃',
        iconColor: AppColors.error,
        textColor: AppColors.error,
        showChevron: false,
        onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
      ),
    ],
  );
}
```

> **참고:** `signOut()` → `state = null` → GoRouter redirect가 자동으로 `/login`으로 이동. 수동 `context.go` 불필요.

**Step 2: 미사용 import 정리**

`auth_result_entity.dart` import가 `_buildProfileHeader`에서 여전히 사용되므로 유지. `_buildMenuList` 시그니처에서 `AuthResultEntity? user` 파라미터가 더 이상 내부에서 사용되지 않으므로 제거 가능 여부 확인 — 단, `_buildProfileHeader`에 전달할 때 `build()`에서 `user`를 공유하므로 호출부에서 정리.

**Step 3: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "refactor: ProfileScreen 게스트/로그인 로그아웃 버튼 통일"
```

---

### Task 3: SocialScreen "로그인하기" 버튼 캐시 정리 보장

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart:58-63`

**Step 1: SocialScreen 게스트 뷰의 버튼 동작 확인**

현재 `signOut()`을 호출 후 `context.go(RoutePaths.login)` — `signOut()`이 Task 1에서 캐시를 정리하도록 수정됐으므로 캐시 정리는 자동으로 됨. 다만 `signOut()` 후 GoRouter redirect가 자동으로 `/login`으로 보내므로 수동 `context.go` 제거:

```dart
AppButton(
  text: '로그인하기',
  onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
  width: 200,
),
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/social/presentation/screens/social_screen.dart
git commit -m "fix: SocialScreen 게스트 로그인 버튼에서 수동 라우팅 제거"
```

---

## 변경 파일 요약

| # | 파일 | 변경 내용 |
|---|------|----------|
| 1 | `auth_provider.dart` | `signOut()` 게스트 분기에서 `has_seen_onboarding`도 정리 |
| 2 | `profile_screen.dart` | 게스트/로그인 분기 제거, "로그아웃" 통일 |
| 3 | `social_screen.dart` | 수동 `context.go` 제거 (GoRouter redirect 의존) |

총 3개 파일 수정. 신규 파일 없음.

## 검증

1. `flutter analyze` 에러 없음
2. 게스트 → 프로필 → "로그아웃" → 로그인 화면 이동 확인
3. 게스트 → 소셜 → "로그인하기" → 로그인 화면 이동 확인
4. 로그아웃 후 재시작 → 게스트 상태가 아닌 로그인 화면 (캐시 정리됨)
5. 일반 로그인 유저 → 프로필 → "로그아웃" 기존 동작 유지
