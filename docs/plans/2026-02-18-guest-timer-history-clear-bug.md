# 게스트 로그아웃 시 타이머 기록 미초기화 버그 수정 Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 게스트 모드 로그아웃 시 타이머 세션 기록(`guest_timer_sessions`)도 함께 초기화되도록 수정

**Architecture:** Todo 데이터 초기화 패턴(`clearAll()` 체인)을 그대로 따라 Timer 레이어에도 동일하게 적용. DataSource → Repository 인터페이스 → Repository 구현체 → AuthNotifier.signOut() 호출부 순서로 추가.

**Tech Stack:** Flutter, Riverpod, SharedPreferences

---

## 근본 원인

`AuthNotifier.signOut()` 게스트 경로(line 297-306)에서 `todoRepo.clearAll()`만 호출하고 타이머 데이터는 정리하지 않음. 타이머 레이어 전체에 `clearAll()` 메서드 자체가 존재하지 않음.

```
AuthNotifier.signOut() (게스트)
├─ prefs.remove('is_guest')        ✅
├─ todoRepo.clearAll()             ✅ todo + categories 삭제
├─ timerSessionRepo.clearAll()     ❌ 호출 없음 (메서드도 없음)
└─ 'guest_timer_sessions' 키       ❌ 잔존
```

---

### Task 1: Timer 레이어에 clearAll() 추가

**Files:**
- Modify: `lib/features/timer/data/datasources/timer_session_local_datasource.dart`
- Modify: `lib/features/timer/domain/repositories/timer_session_repository.dart`
- Modify: `lib/features/timer/data/repositories/timer_session_repository_impl.dart`

**Step 1: DataSource에 clearAll() 추가**

`timer_session_local_datasource.dart` 맨 아래에 추가:

```dart
Future<void> clearAll() async {
  await _prefs.remove(_sessionsKey);
}
```

**Step 2: Repository 인터페이스에 clearAll() 추가**

`timer_session_repository.dart`:

```dart
abstract class TimerSessionRepository {
  List<TimerSessionEntity> getSessions();
  Future<void> addSession(TimerSessionEntity session);
  Future<void> clearAll();  // ← 추가
}
```

**Step 3: Repository 구현체에 clearAll() 추가**

`timer_session_repository_impl.dart`:

```dart
@override
Future<void> clearAll() async {
  await _localDataSource.clearAll();
}
```

**Step 4: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

### Task 2: signOut()에서 타이머 데이터 정리 호출

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:294-306`

**Step 1: import 추가**

```dart
import '../../../timer/presentation/providers/timer_session_provider.dart';
```

**Step 2: signOut() 게스트 경로에 타이머 정리 코드 추가**

현재 (line 297-306):
```dart
if (currentUser?.isGuest == true) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kIsGuestKey);

  // 게스트 할일 데이터 삭제
  final todoRepo = ref.read(todoRepositoryProvider);
  await todoRepo.clearAll();
  debugPrint('🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories)');
  state = const AsyncValue.data(null);
  return;
}
```

변경:
```dart
if (currentUser?.isGuest == true) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kIsGuestKey);

  // 게스트 할일 데이터 삭제
  final todoRepo = ref.read(todoRepositoryProvider);
  await todoRepo.clearAll();

  // 게스트 타이머 세션 데이터 삭제
  final timerRepo = ref.read(timerSessionRepositoryProvider);
  await timerRepo.clearAll();

  debugPrint('🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories, timer sessions)');
  state = const AsyncValue.data(null);
  return;
}
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/data/datasources/timer_session_local_datasource.dart \
  lib/features/timer/domain/repositories/timer_session_repository.dart \
  lib/features/timer/data/repositories/timer_session_repository_impl.dart \
  lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix: 게스트 로그아웃 시 타이머 세션 기록도 초기화 #27"
```

---

## 변경 요약

| 파일 | 변경 |
|------|------|
| `timer_session_local_datasource.dart` | `clearAll()` 메서드 추가 (1줄) |
| `timer_session_repository.dart` | `clearAll()` 인터페이스 정의 (1줄) |
| `timer_session_repository_impl.dart` | `clearAll()` 구현 (3줄) |
| `auth_provider.dart` | import 추가 + `timerRepo.clearAll()` 호출 (3줄) |

총 변경: 4개 파일, ~10줄 추가
