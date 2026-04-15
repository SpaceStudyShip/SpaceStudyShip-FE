# 소셜 상세 화면 풀스크린 라우팅 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 친구 상세와 학습 랭킹을 Shell 밖 top-level GoRoute로 분리해서 플로팅 바텀 네비게이션 바를 숨기고, 친구 추가 바텀시트는 barrier 더 어둡게 해서 뒤에 비치는 네비 바를 감춘다.

**Architecture:** `StatefulShellRoute.indexedStack` 바깥에 `/friend-detail` / `/ranking` 두 top-level GoRoute를 추가(splash/login/onboarding과 같은 레벨). 친구 상세는 `state.extra`로 `FriendEntity` 전달. Shell 안쪽의 legacy 소셜 서브 라우트(`/social/friends/*`, `/social/groups/*`, `/social/ranking`) 모두 제거. 진입 코드는 `Navigator.push` → `context.push`로 교체. 테스트는 새로 작성하지 않음 (사용자 요청) — 기존 회귀만 확인.

**Tech Stack:** Flutter 3.9 · go_router · Riverpod

**Spec:** `docs/superpowers/specs/2026-04-15-social-fullscreen-routing-design.md`

---

## File Structure

### 수정

| 파일 | 변경 |
|------|------|
| `lib/routes/route_paths.dart` | `friendDetail` 상수 새 경로로 교체, `ranking` 경로 교체, `friends`/`groups`/`groupDetail`/`friendDetailPath`/`groupDetailPath` 제거 |
| `lib/routes/app_router.dart` | `FriendEntity` import, Shell 밖 `friendDetail`/`ranking` 두 GoRoute 추가, Shell 안 소셜 legacy 서브 라우트 전체 제거 |
| `lib/features/social/presentation/widgets/social_seat_view.dart` | `_onSeatTap`에서 `Navigator.push(MaterialPageRoute)` → `context.push(RoutePaths.friendDetail, extra: slot.friend)`, 불필요 import 제거 |
| `lib/features/social/presentation/screens/friend_detail_screen.dart` | `go_router` import 추가, `Navigator.pop(context)` 2곳 → `context.pop()` |
| `lib/features/ranking/presentation/screens/ranking_screen.dart` | `go_router` import 추가, `Navigator.pop(context)` → `context.pop()` |
| `lib/features/social/presentation/widgets/add_friend_sheet.dart` | `showModalBottomSheet`에 `barrierColor: Colors.black.withValues(alpha: 0.72)` 추가 |

### 신규 생성 / 삭제

- 신규 생성: 없음
- 삭제: 없음 (모두 기존 파일 수정)

---

## Task 1: `route_paths.dart` 경로 상수 정리

Shell 밖으로 이동하는 경로에 맞춰 상수를 갱신. legacy 경로는 제거.

**Files:**
- Modify: `lib/routes/route_paths.dart`

- [ ] **Step 1: Social 섹션 교체**

Replace lines 47-57 of `lib/routes/route_paths.dart`:

**Before:**
```dart
  // ═══════════════════════════════════════════════════
  // Social 하위 화면
  // ═══════════════════════════════════════════════════
  static const friends = '/social/friends';
  static const groups = '/social/groups';
  static const ranking = '/social/ranking';

  static const friendDetail = '/social/friends/:id';
  static String friendDetailPath(String id) => '/social/friends/$id';

  static const groupDetail = '/social/groups/:id';
  static String groupDetailPath(String id) => '/social/groups/$id';
```

**After:**
```dart
  // ═══════════════════════════════════════════════════
  // Social 하위 화면 (Shell 밖 top-level, 플로팅 네비 숨김)
  // ═══════════════════════════════════════════════════
  static const ranking = '/ranking';
  static const friendDetail = '/friend-detail';
```

- [ ] **Step 2: 레거시 상수 참조 확인**

```bash
cd /Users/luca/workspace/Flutter_Project/space_study_ship
grep -rn "RoutePaths\.\(friends\|groups\|groupDetail\|friendDetailPath\|groupDetailPath\)" lib/ test/
```

Expected: 결과 없음. 만약 있으면 이 플랜 범위에 포함 안 된 추가 참조 발견 — 보고하고 멈춤.

- [ ] **Step 3: analyze 통과 확인 (중간 — 다음 Task에서 임시 에러 생길 수 있음, 이 Task는 이 파일만)**

```bash
flutter analyze lib/routes/route_paths.dart
```

Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/routes/route_paths.dart
git -c commit.gpgsign=false commit -m "refactor : 소셜 상세 경로 top-level로 이동, legacy friends/groups 경로 제거 #67"
```

---

## Task 2: `app_router.dart` 라우트 재배치

Shell 밖에 `friendDetail`/`ranking` GoRoute 추가하고, Shell 안 소셜 branch의 자식 라우트 정리.

**Files:**
- Modify: `lib/routes/app_router.dart`

- [ ] **Step 1: FriendEntity import 추가**

Edit `lib/routes/app_router.dart` — find the social screen import line:

**Before:**
```dart
import '../features/social/presentation/screens/social_screen.dart';
import '../features/ranking/presentation/screens/ranking_screen.dart';
```

**After:**
```dart
import '../features/social/domain/entities/friend_entity.dart';
import '../features/social/presentation/screens/friend_detail_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/ranking/presentation/screens/ranking_screen.dart';
```

- [ ] **Step 2: Shell 밖 top-level GoRoute 2개 추가**

Edit `lib/routes/app_router.dart` — find the `onboarding` GoRoute closing (the empty line right before `// 메인 탭 (ShellRoute - 바텀 네비게이션)` comment, around line 142) and insert:

```dart
      // ═══════════════════════════════════════════════════
      // 소셜 상세 플로우 (Shell 외부 — 플로팅 네비 숨김)
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: RoutePaths.friendDetail,
        name: 'friendDetail',
        pageBuilder: (context, state) {
          final friend = state.extra as FriendEntity;
          return CustomTransitionPage(
            key: state.pageKey,
            child: FriendDetailScreen(friend: friend),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.ranking,
        name: 'ranking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RankingScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),

```

- [ ] **Step 3: Shell 안 소셜 branch의 legacy 자식 라우트 전체 제거**

Edit `lib/routes/app_router.dart` — find the social StatefulShellBranch (lines ~256-304) and replace it.

**Before:**
```dart
          // 소셜 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.social,
                name: 'social',
                builder: (context, state) => const SocialScreen(),
                routes: [
                  GoRoute(
                    path: 'friends',
                    name: 'friends',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '친구 목록'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'friendDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '친구: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'groups',
                    name: 'groups',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '그룹 목록'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'groupDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '그룹: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'ranking',
                    name: 'ranking',
                    builder: (context, state) => const RankingScreen(),
                  ),
                ],
              ),
            ],
          ),
```

**After:**
```dart
          // 소셜 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.social,
                name: 'social',
                builder: (context, state) => const SocialScreen(),
              ),
            ],
          ),
```

- [ ] **Step 4: analyze 전체 확인**

```bash
flutter analyze
```

Expected: `No issues found!`

주의: 이 시점에선 아직 `social_seat_view.dart`가 `Navigator.push`를 쓰지만 에러는 안 남 (기존 API). 정상.

- [ ] **Step 5: 커밋**

```bash
git add lib/routes/app_router.dart
git -c commit.gpgsign=false commit -m "refactor : 친구 상세·랭킹을 Shell 밖 top-level 라우트로 이동 #67"
```

---

## Task 3: `social_seat_view.dart` 진입 코드 GoRouter로 교체

`_onSeatTap`의 `Navigator.push(MaterialPageRoute)` 호출을 `context.push(RoutePaths.friendDetail, extra: slot.friend)`로 교체.

**Files:**
- Modify: `lib/features/social/presentation/widgets/social_seat_view.dart`

- [ ] **Step 1: `_onSeatTap` 교체**

Edit `lib/features/social/presentation/widgets/social_seat_view.dart`.

**Before:**
```dart
  void _onSeatTap(BuildContext context, SeatSlot slot) {
    if (slot.status == SeatStatus.empty) {
      AddFriendSheet.show(context);
      return;
    }
    if (slot.friend == null || slot.status == SeatStatus.me) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FriendDetailScreen(friend: slot.friend!),
      ),
    );
  }
```

**After:**
```dart
  void _onSeatTap(BuildContext context, SeatSlot slot) {
    if (slot.status == SeatStatus.empty) {
      AddFriendSheet.show(context);
      return;
    }
    if (slot.friend == null || slot.status == SeatStatus.me) return;
    context.push(RoutePaths.friendDetail, extra: slot.friend);
  }
```

- [ ] **Step 2: 불필요해진 `FriendDetailScreen` import 제거 확인**

```bash
grep -n "friend_detail_screen" lib/features/social/presentation/widgets/social_seat_view.dart
```

사용처가 `_onSeatTap` 뿐이었으면 이제 직접 참조가 없으므로 import 라인을 삭제해야 함.

해당 import 라인 제거:
```dart
import '../screens/friend_detail_screen.dart';
```

- [ ] **Step 3: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/social_seat_view.dart
```

Expected: `No issues found!` (unused import 에러 없음)

- [ ] **Step 4: 커밋**

```bash
git add lib/features/social/presentation/widgets/social_seat_view.dart
git -c commit.gpgsign=false commit -m "refactor : 친구 상세 진입을 context.push로 교체 #67"
```

---

## Task 4: `friend_detail_screen.dart` Navigator → GoRouter pop

Back arrow와 친구 삭제 후 pop을 모두 `context.pop()`으로 교체. go_router import 추가.

**Files:**
- Modify: `lib/features/social/presentation/screens/friend_detail_screen.dart`

- [ ] **Step 1: go_router import 추가**

Edit `lib/features/social/presentation/screens/friend_detail_screen.dart` — add to imports section (after `flutter_screenutil`):

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: back arrow의 `Navigator.pop` 교체**

**Before:**
```dart
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
```

**After:**
```dart
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => context.pop(),
        ),
```

- [ ] **Step 3: `_confirmDelete` 안의 `Navigator.pop` 교체**

**Before:**
```dart
    if (!context.mounted) return;
    if (ok == true) {
      Navigator.pop(context);
      AppSnackBar.success(context, '${friend.name}님을 삭제했어요');
    }
```

**After:**
```dart
    if (!context.mounted) return;
    if (ok == true) {
      context.pop();
      AppSnackBar.success(context, '${friend.name}님을 삭제했어요');
    }
```

- [ ] **Step 4: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/screens/friend_detail_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/social/presentation/screens/friend_detail_screen.dart
git -c commit.gpgsign=false commit -m "refactor : FriendDetailScreen Navigator.pop → context.pop #67"
```

---

## Task 5: `ranking_screen.dart` Navigator → GoRouter pop

**Files:**
- Modify: `lib/features/ranking/presentation/screens/ranking_screen.dart`

- [ ] **Step 1: go_router import 추가**

Edit `lib/features/ranking/presentation/screens/ranking_screen.dart` — add to imports (after `flutter_riverpod`):

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: back arrow의 `Navigator.pop` 교체**

**Before:**
```dart
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
```

**After:**
```dart
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => context.pop(),
        ),
```

- [ ] **Step 3: analyze 확인**

```bash
flutter analyze lib/features/ranking/presentation/screens/ranking_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/ranking/presentation/screens/ranking_screen.dart
git -c commit.gpgsign=false commit -m "refactor : RankingScreen Navigator.pop → context.pop #67"
```

---

## Task 6: `add_friend_sheet.dart` barrier 어둡게

**Files:**
- Modify: `lib/features/social/presentation/widgets/add_friend_sheet.dart`

- [ ] **Step 1: `showModalBottomSheet` 호출에 `barrierColor` 추가**

Edit `lib/features/social/presentation/widgets/add_friend_sheet.dart`.

**Before:**
```dart
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.spaceSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.modal,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const AddFriendSheet(),
      ),
    );
  }
```

**After:**
```dart
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.spaceSurface,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.modal,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const AddFriendSheet(),
      ),
    );
  }
```

- [ ] **Step 2: analyze 확인**

```bash
flutter analyze lib/features/social/presentation/widgets/add_friend_sheet.dart
```

Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/features/social/presentation/widgets/add_friend_sheet.dart
git -c commit.gpgsign=false commit -m "feat : AddFriendSheet barrier 어둡게 조정 #67"
```

---

## Task 7: 최종 검증

전체 빌드 + 테스트 회귀 + grep 사이드 이펙트 체크.

**Files:** (read only)

- [ ] **Step 1: 전체 analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: 전체 Navigator.push/pop 사이드 이펙트 체크 — 소셜/랭킹 영역에 남아있는지 확인**

```bash
grep -rn "Navigator\.push\|Navigator\.pop" lib/features/social/ lib/features/ranking/
```

Expected: 결과 0건. 만약 `showModalBottomSheet` 안의 `Navigator.pop(ctx, ...)` 같은 게 있으면 **그것은 놔둬도 됨** (바텀시트 내부 dismiss는 GoRouter 대상 아님). 하지만 **screen 단위 push/pop**은 전부 교체되어야 함.

수동 확인: `add_friend_sheet.dart`와 `friend_detail_screen.dart`의 `Navigator.pop(ctx, _FriendAction.delete)` 같은 bottom sheet dismiss 호출은 남아있을 수 있음 (의도적 — modal 내부 닫기용). 이건 GoRouter가 아니라 `showModalBottomSheet`가 return하는 Navigator를 쓰는 거라 그대로 둠.

- [ ] **Step 3: 기존 social 테스트 회귀 확인**

```bash
flutter test test/features/social/
```

Expected: 23 tests pass. (기존 `friend_detail_screen_test.dart`는 `FriendDetailScreen`을 직접 pump하므로 라우팅 변경 영향 없음)

- [ ] **Step 4: 혹시 ranking 테스트가 있는지 확인**

```bash
ls test/features/ranking/ 2>/dev/null || echo "no ranking tests"
```

랭킹 테스트가 없으면 "no ranking tests" 출력. 있으면 실행해 회귀 확인:

```bash
flutter test test/features/ranking/ 2>&1 | tail -5
```

Expected: 있으면 전부 pass, 없으면 이 단계 스킵.

- [ ] **Step 5: 커밋 없음 (검증 단계)**

이 Task는 검증만 — 코드 변경 없음. Task 2~6에서 각각 커밋된 상태 그대로.

---

## Self-Review

### 1. Spec 커버리지

| Spec 섹션 | 구현 Task |
|----------|-----------|
| 3.1 친구 상세 & 학습 랭킹 → Shell 밖 top-level GoRoute | Task 2 |
| 3.2 친구 추가 바텀시트 barrier 어둡게 | Task 6 |
| 4.1 친구 상세 `/friend-detail` 라우트 사양 | Task 1 (상수) + Task 2 (GoRoute builder) |
| 4.2 학습 랭킹 `/ranking` 라우트 사양 | Task 1 (상수) + Task 2 (GoRoute builder) |
| 4.3 제거할 기존 라우트 (`/social/friends/*`, `/social/groups/*`, `/social/ranking`) | Task 2 (Shell 안 소셜 branch 정리) |
| 4.4 `route_paths.dart` 변경 | Task 1 |
| 5.1 `social_seat_view.dart` Navigator → context.push | Task 3 |
| 5.2 `friend_detail_screen.dart` Navigator.pop → context.pop | Task 4 |
| 5.3 `ranking_screen.dart` Navigator.pop → context.pop | Task 5 |
| 6. `add_friend_sheet.dart` barrierColor | Task 6 |
| 7. 영향 범위 체크 (6개 파일) | Task 1~6 각각 대응 |
| 8. 엣지 케이스 (state.extra 캐스팅) | Task 2 Step 2의 `as FriendEntity` |
| 9. In Scope 전체 | Task 1~7 |

### 2. Placeholder 스캔

- "TBD" / "TODO" / "implement later": 없음
- "Similar to Task N": 없음 — Task 4/5가 유사하지만 각각 실제 코드 블록을 반복
- "Add appropriate error handling": 없음
- 모든 Step에 실제 코드 또는 실행 명령 포함

### 3. 타입 일관성

- `RoutePaths.friendDetail` — Task 1에서 `/friend-detail` 문자열로 정의, Task 2 GoRoute path + Task 3 `context.push` 호출에서 동일 참조 ✓
- `RoutePaths.ranking` — Task 1에서 `/ranking`으로 정의, Task 2 GoRoute path에서 동일 참조 ✓
- `state.extra as FriendEntity` — Task 2에서 사용, Task 3에서 `extra: slot.friend`로 `FriendEntity?`를 전달 (slot.friend는 앞선 null-check로 non-null 보장) ✓
- `CustomTransitionPage` — 기존 `splash`/`login`/`onboarding`에서 이미 사용 중이라 추가 import 불필요 ✓
- `FriendDetailScreen(friend:)` 생성자 시그니처 — 기존 D2 구현 그대로 사용 ✓
- `RankingScreen()` const 생성자 — 기존 그대로 ✓
- `context.push` / `context.pop` — `go_router` extension, Task 4/5에서 import 추가 ✓

모든 타입/경로 일관성 확인 완료.
