# Guest Mode History Clear Bug Fix Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 게스트 모드 로그아웃 → 재진입 시 타이머 기록(history)이 초기화되지 않는 버그 수정

**Architecture:** `signOut()`에서 SharedPreferences는 정리하지만 Riverpod Provider 상태를 invalidate하지 않아 발생. `signInAsGuest()`에서도 이전 세션 잔여 데이터를 방어적으로 정리해야 함.

**Tech Stack:** Flutter, Riverpod, SharedPreferences

---

## Root Cause Analysis

### 현재 흐름
```
signOut() (게스트)
  ├─ prefs.remove(kIsGuestKey)          ✅ SharedPreferences 정리
  ├─ todoRepo.clearAll()                ✅ SharedPreferences 정리
  ├─ timerRepo.clearAll()               ✅ SharedPreferences 정리
  ├─ state = AsyncValue.data(null)      ✅ Auth 상태 초기화
  └─ ref.invalidate(providers)          ❌ 누락! → 메모리 내 캐시 유지

signInAsGuest()
  ├─ prefs.setBool(kIsGuestKey, true)   ✅ 게스트 플래그 설정
  ├─ state = AuthResultEntity(...)      ✅ Auth 상태 설정
  └─ 잔여 데이터 clearAll()              ❌ 누락! → 앱 강종 후 재진입 시 이전 데이터 잔류
```

### 버그 시나리오
1. 게스트 모드 진입 → 타이머 사용 → 세션 기록 생성
2. 로그아웃 → SharedPreferences는 지워지지만 `timerSessionListNotifierProvider`는 메모리에 stale 데이터 보유
3. 다시 게스트 로그인 → Provider가 아직 dispose 안 됐으면 이전 기록이 그대로 표시

### 보조 시나리오 (앱 강제 종료)
1. 게스트 모드에서 타이머 사용 → 앱 강종 (signOut 미호출)
2. 앱 재실행 → `is_guest` 플래그와 함께 `guest_timer_sessions` 데이터 잔류
3. 게스트 모드 재진입 시 이전 세션이 그대로 로드

---

### Task 1: signOut() 게스트 모드에서 Provider 상태 invalidate 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:310-315`

**Step 1: signOut()의 게스트 분기에 ref.invalidate 추가**

현재 코드 (310-315):
```dart
      debugPrint(
        '🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories, timer sessions)',
      );
      state = const AsyncValue.data(null);
      return;
```

변경:
```dart
      // Riverpod Provider 메모리 캐시 강제 초기화
      ref.invalidate(timerSessionListNotifierProvider);
      ref.invalidate(todoListNotifierProvider);
      ref.invalidate(categoryListNotifierProvider);

      debugPrint(
        '🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories, timer sessions)',
      );
      state = const AsyncValue.data(null);
      return;
```

**Step 2: 필요 import 추가**

`timer_session_provider.dart`에서 `timerSessionListNotifierProvider` import 필요 여부 확인 후 추가.

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

### Task 2: signInAsGuest()에서 잔여 데이터 방어적 정리

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:280-291`

**Step 1: signInAsGuest()에 clearAll + invalidate 추가**

현재 코드:
```dart
  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIsGuestKey, true);
    state = const AsyncValue.data(
      AuthResultEntity(
        userId: -1,
        nickname: '게스트',
        isNewUser: false,
        isGuest: true,
      ),
    );
  }
```

변경:
```dart
  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIsGuestKey, true);

    // 이전 게스트 세션 잔여 데이터 방어적 정리 (앱 강종 대비)
    final todoRepo = ref.read(todoRepositoryProvider);
    await todoRepo.clearAll();
    final timerRepo = ref.read(timerSessionRepositoryProvider);
    await timerRepo.clearAll();

    ref.invalidate(timerSessionListNotifierProvider);
    ref.invalidate(todoListNotifierProvider);
    ref.invalidate(categoryListNotifierProvider);

    state = const AsyncValue.data(
      AuthResultEntity(
        userId: -1,
        nickname: '게스트',
        isNewUser: false,
        isGuest: true,
      ),
    );
  }
```

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

### Task 3: 검증 및 커밋

**Step 1: 변경 내용 검증**

`signOut()` (게스트):
- [x] SharedPreferences clearAll ✅ (기존)
- [x] ref.invalidate 3개 Provider ✅ (신규)

`signInAsGuest()`:
- [x] 잔여 데이터 clearAll ✅ (신규)
- [x] ref.invalidate 3개 Provider ✅ (신규)

**Step 2: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix: 게스트 모드 전환 시 타이머 기록 미초기화 버그 수정 #27"
```

---

## Summary

| 위치 | Before | After |
|------|--------|-------|
| `signOut()` 게스트 | clearAll만 호출 | clearAll + ref.invalidate 3개 |
| `signInAsGuest()` | 게스트 플래그 설정만 | clearAll + ref.invalidate 3개 + 게스트 플래그 |
| 수정 파일 | 0 | 1개 (`auth_provider.dart`) |
