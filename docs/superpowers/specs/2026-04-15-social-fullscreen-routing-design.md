# 소셜 상세 화면 풀스크린 라우팅 개선 스펙

**Date:** 2026-04-15
**Branch:** `20260412_#67_소셜_화면_UI_UX_구체화_탑승권_테마_레이아웃_설계`
**Status:** Approved for planning

---

## 1. 목표

소셜 탭에서 진입하는 상세 화면(친구 상세, 학습 랭킹)을 풀스크린으로 표시해 플로팅 바텀 네비게이션 바를 숨긴다. 친구 추가 바텀시트는 유지하되 backdrop을 더 어둡게 만들어 뒤에 비치는 네비 바를 감춘다.

### 해결하려는 문제

1. **친구 상세 화면** — `Navigator.push(MaterialPageRoute)`로 띄워서 `StatefulShellRoute` 안쪽 Navigator에 쌓임 → `MainShell`이 유지되어 플로팅 네비 바가 계속 보임. 몰입도 저하.

2. **학습 랭킹 화면** — `/social/ranking`이 `StatefulShellRoute` 소셜 branch의 자식 GoRoute로 등록되어 있어 탭 이동 없이도 MainShell이 유지됨.

3. **친구 추가 바텀시트** — 모달이 뜨는데 플로팅 네비 바가 Scaffold body 밖 Stack 상단에 위치해 모달 barrier 위에 표시됨. 시각적으로 산만.

---

## 2. 설계 원칙

- **drill-down 상세 화면**은 풀스크린 (몰입)
- **짧은 서브태스크**(친구 추가 같은)는 모달 유지 (가볍게)
- iOS/Android HIG 관례 준수: 상세 뷰 진입 시 네비 바 숨김이 표준

---

## 3. 최종 디자인

### 3.1 친구 상세 & 학습 랭킹 → Shell 밖 top-level GoRoute

`StatefulShellRoute.indexedStack` **바깥**, 기존 `splash`/`login`/`onboarding`과 같은 레벨로 이동.

**변경 전 (Shell 자식):**
```
StatefulShellRoute.indexedStack(
  branches: [
    social: [
      /social → SocialScreen
        /social/ranking → RankingScreen        ← Shell 안쪽
        /social/friends/:id → PlaceholderScreen ← legacy, 미사용
    ]
  ]
)
```

**변경 후 (Shell 밖):**
```
routes: [
  /splash, /login, /onboarding,
  /friend-detail     ← NEW (Shell 밖, top-level)
  /ranking           ← 이동 (Shell 밖, top-level)
  StatefulShellRoute.indexedStack(...)
]
```

### 3.2 친구 추가 바텀시트 → barrier 어둡게

`AddFriendSheet.show()`의 `showModalBottomSheet` 호출에 `barrierColor: Colors.black.withValues(alpha: 0.72)` 추가. 플로팅 네비가 시각적으로 거의 사라짐.

---

## 4. 라우트 사양

### 4.1 친구 상세 (`/friend-detail`)

- **Path:** `/friend-detail` (param 없음)
- **Name:** `friendDetail`
- **Transition:** iOS 기본 push (slide from right)
- **Data:** `state.extra`로 `FriendEntity` 전달 (딥링크 불필요 — 소셜은 게스트 차단)
- **Builder:**
  ```dart
  GoRoute(
    path: '/friend-detail',
    name: 'friendDetail',
    pageBuilder: (context, state) {
      final friend = state.extra as FriendEntity;
      return CupertinoPage(
        key: state.pageKey,
        child: FriendDetailScreen(friend: friend),
      );
    },
  ),
  ```

### 4.2 학습 랭킹 (`/ranking`)

- **Path:** `/ranking`
- **Name:** `ranking`
- **Transition:** iOS 기본 push
- **Data:** 없음 (Provider로 읽음)
- **Builder:**
  ```dart
  GoRoute(
    path: '/ranking',
    name: 'ranking',
    pageBuilder: (context, state) => CupertinoPage(
      key: state.pageKey,
      child: const RankingScreen(),
    ),
  ),
  ```

### 4.3 제거할 기존 라우트

Shell 안쪽의 소셜 branch:
- `/social/ranking` (RankingScreen) — top-level로 이동
- `/social/friends`, `/social/friends/:id`, `/social/groups`, `/social/groups/:id` — **legacy PlaceholderScreen**, 미사용 → 삭제

### 4.4 route_paths.dart 변경

```dart
// 제거
static const friends = '/social/friends';
static const friendDetail = '/social/friends/:id';
static String friendDetailPath(String id) => '/social/friends/$id';

// 추가/변경
static const ranking = '/ranking';                        // 기존 /social/ranking에서 변경
static const friendDetail = '/friend-detail';             // 새 경로
```

---

## 5. Navigator.push → context.push 마이그레이션

### 5.1 `social_seat_view.dart`

**변경 전:**
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

**변경 후:**
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

### 5.2 `friend_detail_screen.dart`

- `Navigator.pop(context)` 2곳 → `context.pop()` (GoRouter 일관성)
  - Line 35 (back arrow)
  - Line 198 (친구 삭제 후)
- import 추가: `import 'package:go_router/go_router.dart';`

### 5.3 `ranking_screen.dart`

- `Navigator.pop(context)` → `context.pop()`

---

## 6. 친구 추가 바텀시트 변경

### `add_friend_sheet.dart`

```dart
static Future<void> show(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.spaceSurface,
    barrierColor: Colors.black.withValues(alpha: 0.72),  // ← 추가
    shape: RoundedRectangleBorder(borderRadius: AppRadius.modal),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const AddFriendSheet(),
    ),
  );
}
```

---

## 7. 영향 범위 체크

| 파일 | 변경 유형 | 상세 |
|------|----------|------|
| `lib/routes/app_router.dart` | 수정 | Shell 밖 2개 GoRoute 추가, Shell 안 legacy 소셜 서브 라우트 제거 |
| `lib/routes/route_paths.dart` | 수정 | `ranking` 경로 변경, `friendDetail` 경로 변경, `friends` 관련 legacy 제거 |
| `lib/features/social/presentation/widgets/social_seat_view.dart` | 수정 | `Navigator.push` → `context.push`, import 정리 |
| `lib/features/social/presentation/screens/friend_detail_screen.dart` | 수정 | `Navigator.pop` 2곳 → `context.pop`, go_router import 추가 |
| `lib/features/ranking/presentation/screens/ranking_screen.dart` | 수정 | `Navigator.pop` → `context.pop`, go_router import 추가 |
| `lib/features/social/presentation/widgets/add_friend_sheet.dart` | 수정 | `barrierColor` 추가 |

**테스트 영향:**
- `friend_detail_screen_test.dart` — 직접 pump라 영향 없음
- social 기존 테스트 — `Navigator.push` 직접 검증 없음 → 영향 없음

---

## 8. 엣지 케이스

| 상황 | 처리 |
|------|------|
| 친구 상세에서 하드웨어 back | `context.pop()` 자동 → 소셜 화면 복귀 |
| 친구 상세에서 친구 삭제 | `context.pop()` → 소셜 화면 (좌석은 더미라 유지) |
| 랭킹에서 back | `context.pop()` → 소셜 화면 |
| `state.extra`가 null (비정상 딥링크) | 이번 스코프에서는 게스트 차단 + 내부 진입만 있어 불가능. 일단 `as FriendEntity`로 캐스팅. 추후 딥링크 지원 시 null guard 추가 |
| 친구 추가 시트 배경 탭 | 기존 동작 그대로 — 시트 닫힘 |

---

## 9. 구현 범위

### In Scope
- [ ] `route_paths.dart`에 `friendDetail` 상수 추가, `ranking` 경로 업데이트, legacy `friends` 제거
- [ ] `app_router.dart`에 top-level `/friend-detail`, `/ranking` GoRoute 추가
- [ ] `app_router.dart`에서 Shell 안 소셜 legacy 서브 라우트 제거
- [ ] `social_seat_view.dart` — `Navigator.push` → `context.push(RoutePaths.friendDetail, extra: friend)`
- [ ] `friend_detail_screen.dart` — `Navigator.pop` → `context.pop` (2곳)
- [ ] `ranking_screen.dart` — `Navigator.pop` → `context.pop`
- [ ] `add_friend_sheet.dart` — `barrierColor: Colors.black.withValues(alpha: 0.72)` 추가
- [ ] `flutter analyze` 통과
- [ ] 기존 social 테스트 (23개) 전부 통과

### Out of Scope
- 딥링크 지원 (`/friend-detail/:id` path param)
- 친구 상세 pageBuilder 커스텀 애니메이션 (Cupertino 기본 사용)
- 친구 추가를 풀스크린 route로 승격
- 그룹 관련 (`/social/groups/*`) 실제 구현 — 이번 스코프는 legacy 정리만

---

## 10. 위젯 분리 원칙

라우팅 변경이 주 목적이라 새 위젯 분리는 없음. 기존 public API(`FriendDetailScreen(friend:)`, `RankingScreen()`, `AddFriendSheet.show(context)`)는 모두 유지.
