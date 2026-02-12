# 로그아웃 플로우 정리 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 일반 로그아웃(유저 액션)과 강제 로그아웃(401 토큰 만료)을 명확히 분리하고, 강제 로그아웃 시에도 Firebase 정리 + 로그인 화면 이동이 보장되도록 한다.

**Architecture:** Repository에 `forceSignOut()`(서버 호출 없이 Firebase+토큰 정리) 추가 → AuthNotifier에 `forceLogout()` 추가 → AuthInterceptor의 `onLoggedOut` 콜백을 dio_client에서 연결하여 401 시 자동 강제 로그아웃 → GoRouter redirect가 로그인 화면으로 이동

**Tech Stack:** Flutter, Riverpod, Dio Interceptor, GoRouter redirect

---

## 플로우 다이어그램

```
[일반 로그아웃] — 유저가 프로필에서 로그아웃 버튼 클릭
  context.go(/login)
  → 백엔드 POST /logout (실패해도 OK)
  → Firebase signOut
  → clearTokens
  → state = unauthenticated

[강제 로그아웃] — AuthInterceptor에서 401 + refresh 실패
  → Firebase signOut
  → clearTokens
  → state = unauthenticated
  → GoRouter redirect → /login
```

---

### Task 1: Repository에 forceSignOut() 추가

**Files:**
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Step 1: 인터페이스에 forceSignOut() 추가**

`lib/features/auth/domain/repositories/auth_repository.dart`에 메서드 추가:

```dart
/// 강제 로그아웃 (서버 호출 없이 Firebase + 토큰 삭제)
/// 401 토큰 만료 시 AuthInterceptor에서 호출됩니다.
Future<void> forceSignOut();
```

**Step 2: 구현체에 forceSignOut() 구현**

`lib/features/auth/data/repositories/auth_repository_impl.dart`에 추가:

```dart
@override
Future<void> forceSignOut() async {
  // 서버 호출 없이 로컬 정리만 수행
  await _firebaseAuthDataSource.signOut();
  await _tokenStorage.clearTokens();
  debugPrint('[AuthRepository] 강제 로그아웃 완료');
}
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/auth/domain/repositories/auth_repository.dart lib/features/auth/data/repositories/auth_repository_impl.dart
git commit -m "feat: Repository에 forceSignOut() 메서드 추가"
```

---

### Task 2: AuthNotifier에 forceLogout() 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: forceLogout() 메서드 추가**

`AuthNotifier` 클래스에 추가:

```dart
/// 강제 로그아웃 (401 토큰 만료 시)
///
/// 서버 호출 없이 Firebase + 토큰 정리 후 상태를 unauthenticated로 변경합니다.
/// AuthInterceptor의 onLoggedOut 콜백에서 호출됩니다.
Future<void> forceLogout() async {
  try {
    final repository = ref.read(authRepositoryProvider);
    await repository.forceSignOut();
  } catch (e) {
    debugPrint('[Auth] 강제 로그아웃 중 오류: $e');
  }
  // 오류 여부와 상관없이 상태 변경 (로그인 화면으로 이동 보장)
  state = const AsyncValue.data(AuthStatus.unauthenticated);
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `auth_provider.g.dart` 재생성

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart lib/features/auth/presentation/providers/auth_provider.g.dart
git commit -m "feat: AuthNotifier에 forceLogout() 메서드 추가"
```

---

### Task 3: AuthInterceptor onLoggedOut 콜백 연결

**Files:**
- Modify: `lib/core/services/dio/dio_client.dart`

**Step 1: onLoggedOut 콜백 연결**

`dio_client.dart`의 AuthInterceptor 생성 부분 수정:

```dart
AuthInterceptor(
  dio,
  SecureTokenStorage(),
  onLoggedOut: () {
    ref.read(authNotifierProvider.notifier).forceLogout();
  },
),
```

**주의:** `auth_provider.dart` import 추가 필요:
```dart
import '../../../features/auth/presentation/providers/auth_provider.dart';
```

**Step 2: AuthInterceptor.onError에서 Firebase signOut도 수행하도록 확인**

현재 `auth_interceptor.dart`의 onError에서 refresh 실패 시:
- `_tokenStorage.clearTokens()` 후 `onLoggedOut?.call()` 호출

이미 onLoggedOut → forceLogout() → forceSignOut() (Firebase + clearTokens) 를 호출하므로
중복 clearTokens가 발생하지만 무해함. AuthInterceptor 쪽의 clearTokens는 제거하여 깔끔하게.

`lib/core/services/dio/interceptors/auth_interceptor.dart` 수정:

refresh 실패 시 (line 65-68, line 72-74):
```dart
// 변경 전:
await _tokenStorage.clearTokens();
onLoggedOut?.call();

// 변경 후:
onLoggedOut?.call();
```

두 곳 모두 (refreshed == false 분기, catch 분기)에서 `_tokenStorage.clearTokens()` 제거.
`onLoggedOut`이 null이 아니면 forceLogout()이 정리를 담당.
null인 경우(안전장치) 기존 동작 유지를 위해:

```dart
if (onLoggedOut != null) {
  onLoggedOut!.call();
} else {
  await _tokenStorage.clearTokens();
}
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/core/services/dio/dio_client.dart lib/core/services/dio/interceptors/auth_interceptor.dart
git commit -m "feat: AuthInterceptor onLoggedOut 콜백으로 강제 로그아웃 연결"
```

---

### Task 4: Mock 인터셉터에 401 테스트 엔드포인트 추가 (선택)

**Files:**
- Modify: `lib/core/services/dio/interceptors/mock_api_interceptor.dart`

**Step 1: 401 테스트용 mock 핸들러 추가**

강제 로그아웃 플로우 테스트를 위해, 특정 엔드포인트에서 401 반환:

```dart
// _handlers 맵에 추가:
'GET /api/v1/test/force-401': _handleForce401,

// 핸들러:
Response _handleForce401(RequestOptions options) {
  return Response(
    requestOptions: options,
    statusCode: 401,
    data: {'error': 'Token expired (mock)'},
  );
}
```

**주의:** 이 핸들러는 mock에서 `handler.resolve()`로 401 응답을 보내므로, Dio는 이를 에러로 처리함 → AuthInterceptor.onError가 트리거됨.

단, Dio는 status code가 200-299 범위가 아니면 DioException을 throw하므로 resolve 대신:

```dart
Response _handleForce401(RequestOptions options) {
  throw DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: 401,
      data: {'error': 'Token expired (mock)'},
    ),
    type: DioExceptionType.badResponse,
  );
}
```

그리고 `onRequest`에서 `handler.reject()`로 처리:

```dart
if (mockHandler != null) {
  debugPrint('🔀 [MockAPI] $key → mock 응답 반환');
  try {
    final response = mockHandler(options);
    return handler.resolve(response);
  } on DioException catch (e) {
    return handler.reject(e);
  }
}
```

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/core/services/dio/interceptors/mock_api_interceptor.dart
git commit -m "feat: mock 인터셉터에 401 테스트 엔드포인트 추가"
```

---

## 변경 파일 요약

| # | 파일 | 변경 |
|---|------|------|
| 1 | `lib/features/auth/domain/repositories/auth_repository.dart` | `forceSignOut()` 인터페이스 추가 |
| 2 | `lib/features/auth/data/repositories/auth_repository_impl.dart` | `forceSignOut()` 구현 (Firebase + clearTokens) |
| 3 | `lib/features/auth/presentation/providers/auth_provider.dart` | `forceLogout()` 메서드 추가 |
| 4 | `lib/core/services/dio/dio_client.dart` | `onLoggedOut` → `forceLogout()` 연결 |
| 5 | `lib/core/services/dio/interceptors/auth_interceptor.dart` | 중복 clearTokens 제거, onLoggedOut에 위임 |
| 6 | `lib/core/services/dio/interceptors/mock_api_interceptor.dart` | (선택) 401 테스트 엔드포인트 |
