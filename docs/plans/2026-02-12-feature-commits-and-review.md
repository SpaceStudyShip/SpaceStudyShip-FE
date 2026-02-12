# Auth 시스템 기능별 커밋 & 코드 리뷰

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 현재 unstaged 변경 사항을 기능별 커밋 8개로 분리하고, 각 커밋 전 코드 리뷰 수행

**Architecture:** Clean Architecture 3-Layer (Data → Domain → Presentation) + Riverpod 2.x + Firebase Auth

**Tech Stack:** Flutter, Riverpod, Firebase Auth, Dio/Retrofit, Freezed, GoRouter

---

## 현재 상태 요약

**Modified (15 files)** + **Untracked (~40 files)** = Auth 시스템 전체 구현

---

## Task 1: Firebase/소셜 로그인 의존성 및 플랫폼 설정

**커밋 메시지:** `chore: Firebase Auth 및 소셜 로그인 의존성 추가`

**Files:**
- Modified: `pubspec.yaml`
- Modified: `pubspec.lock`
- Modified: `android/app/google-services.json`
- Modified: `ios/Podfile.lock`
- Modified: `ios/Runner/GoogleService-Info.plist`
- Modified: `ios/Runner/Info.plist`
- Modified: `ios/Runner/Runner.entitlements`
- Modified: `macos/Flutter/GeneratedPluginRegistrant.swift`
- Modified: `windows/flutter/generated_plugin_registrant.cc`
- Modified: `windows/flutter/generated_plugins.cmake`
- New: `assets/icons/icon_google.svg`
- New: `assets/icons/icon_apple.svg`

**리뷰 포인트:**
- [ ] `pubspec.yaml`: `firebase_auth`, `google_sign_in`, `sign_in_with_apple` 버전 적절성
- [ ] `pubspec.yaml`: `retrofit: 4.7.3` 고정 (4.9.x logError 호환성 이슈) — 주석 확인
- [ ] `pubspec.yaml`: `assets/icons/` 에셋 폴더 등록
- [ ] `Info.plist`: Google URL Scheme (`com.googleusercontent.apps.754883540966-...`) 확인
- [ ] `Runner.entitlements`: Apple Sign-In capability 추가 확인
- [ ] SVG 아이콘 파일 존재 확인

**Step 1: 리뷰 수행**

`/review` 스킬로 위 파일들 리뷰

**Step 2: 커밋**

```bash
git add pubspec.yaml pubspec.lock android/app/google-services.json ios/Podfile.lock ios/Runner/GoogleService-Info.plist ios/Runner/Info.plist ios/Runner/Runner.entitlements macos/Flutter/GeneratedPluginRegistrant.swift windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake assets/icons/
git commit -m "chore: Firebase Auth 및 소셜 로그인 의존성 추가"
```

---

## Task 2: Core 인프라 (에러, 네트워크, 스토리지, 환경설정)

**커밋 메시지:** `feat: 에러 처리, Dio 네트워크, 토큰 스토리지 인프라 구축`

**Files:**
- New: `lib/core/errors/app_exception.dart`
- New: `lib/core/errors/failure.dart`
- New: `lib/core/constants/api_endpoints.dart`
- New: `lib/core/network/api_error_response.dart`
- New: `lib/core/network/auth_interceptor.dart`
- New: `lib/core/network/dio_client.dart`
- New: `lib/core/network/dio_exception_handler.dart`
- New: `lib/core/network/websocket/_placeholder.dart`
- New: `lib/core/storage/secure_token_storage.dart`
- Modified: `lib/core/config/env_config.dart`

**리뷰 포인트:**
- [ ] `app_exception.dart`: 예외 계층 구조 (AppException → AuthException, NetworkException 등)
- [ ] `dio_client.dart`: 인터셉터 체인 순서 (Auth → Log), baseUrl 설정
- [ ] `auth_interceptor.dart`: 401 처리 + 토큰 재발급 로직, 강제 로그아웃 콜백
- [ ] `dio_exception_handler.dart`: DioException → AppException 변환 매핑
- [ ] `secure_token_storage.dart`: FlutterSecureStorage 키 네이밍, 토큰 CRUD
- [ ] `env_config.dart`: `flutter_dotenv` 로드, `useMockApi` getter, 포트 8000→8080 변경
- [ ] `api_endpoints.dart`: 엔드포인트 상수 정의

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/core/errors/ lib/core/constants/api_endpoints.dart lib/core/network/ lib/core/storage/ lib/core/config/env_config.dart
git commit -m "feat: 에러 처리, Dio 네트워크, 토큰 스토리지 인프라 구축"
```

---

## Task 3: Auth 도메인 레이어

**커밋 메시지:** `feat: Auth 도메인 레이어 (Entity, Repository 인터페이스, UseCase)`

**Files:**
- New: `lib/features/auth/domain/entities/auth_result_entity.dart`
- New: `lib/features/auth/domain/entities/auth_result_entity.freezed.dart`
- New: `lib/features/auth/domain/repositories/auth_repository.dart`
- New: `lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart`
- New: `lib/features/auth/domain/usecases/sign_in_with_apple_usecase.dart`
- New: `lib/features/auth/domain/usecases/sign_out_usecase.dart`
- New: `lib/features/auth/domain/utils/firebase_auth_error_handler.dart`

**리뷰 포인트:**
- [ ] `auth_result_entity.dart`: Freezed 모델 필드 (userId, nickname, isNewUser)
- [ ] `auth_repository.dart`: 추상 클래스, 메서드 시그니처 (signInWithGoogle/Apple, signOut)
- [ ] UseCase들: 단일 책임, `execute()` 메서드 패턴
- [ ] `firebase_auth_error_handler.dart`: Firebase 에러 코드 → 사용자 메시지 매핑

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/features/auth/domain/
git commit -m "feat: Auth 도메인 레이어 (Entity, Repository 인터페이스, UseCase)"
```

---

## Task 4: Auth 데이터 레이어

**커밋 메시지:** `feat: Auth 데이터 레이어 (DataSource, Model, Repository 구현체)`

**Files:**
- New: `lib/features/auth/data/datasources/auth_remote_datasource.dart` + `.g.dart`
- New: `lib/features/auth/data/datasources/firebase_auth_datasource.dart`
- New: `lib/features/auth/data/models/login_request_model.dart` + `.freezed.dart` + `.g.dart`
- New: `lib/features/auth/data/models/login_response_model.dart` + `.freezed.dart` + `.g.dart`
- New: `lib/features/auth/data/models/logout_request_model.dart` + `.freezed.dart` + `.g.dart`
- New: `lib/features/auth/data/models/token_reissue_request_model.dart` + `.freezed.dart` + `.g.dart`
- New: `lib/features/auth/data/models/token_reissue_response_model.dart` + `.freezed.dart` + `.g.dart`
- New: `lib/features/auth/data/repositories/auth_repository_impl.dart`

**리뷰 포인트:**
- [ ] `auth_remote_datasource.dart`: Retrofit 엔드포인트 정의, API 스펙 일치
- [ ] `firebase_auth_datasource.dart`: Google/Apple 로그인 흐름, getIdToken, signOut
- [ ] Model들: Freezed 정의, `@JsonKey(name:)` snake_case 매핑
- [ ] `auth_repository_impl.dart`: Firebase → Backend 로그인 흐름, Firebase-only 모드 임시 구현
- [ ] `auth_repository_impl.dart`: 에러 처리 (DioException, FirebaseAuthException, AppException)

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/features/auth/data/
git commit -m "feat: Auth 데이터 레이어 (DataSource, Model, Repository 구현체)"
```

---

## Task 5: Auth 프레젠테이션 레이어 (Provider + 소셜 로그인 버튼)

**커밋 메시지:** `feat: Auth Provider 및 소셜 로그인 버튼 위젯`

**Files:**
- New: `lib/features/auth/presentation/providers/auth_provider.dart` + `.g.dart`
- New: `lib/core/widgets/buttons/social_login_button.dart`

**리뷰 포인트:**
- [ ] `auth_provider.dart`: Provider 의존성 체인 (DataSource → Repository → UseCase → Notifier)
- [ ] `auth_provider.dart`: `AuthNotifier` — signIn에 `rethrow` 포함, `finally`에서 `activeLogin.clear()`
- [ ] `auth_provider.dart`: `ActiveLoginNotifier` — 버튼별 로딩 상태 추적
- [ ] `auth_provider.dart`: `SecureTokenStorage/Dio` keepAlive 설정
- [ ] `social_login_button.dart`: Google/Apple 버튼 — AppButton 기반, SVG 아이콘, 색상 스펙

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/features/auth/presentation/providers/ lib/core/widgets/buttons/social_login_button.dart
git commit -m "feat: Auth Provider 및 소셜 로그인 버튼 위젯"
```

---

## Task 6: 로그인/스플래시 스크린 리팩터링

**커밋 메시지:** `feat: 로그인 스크린 소셜 로그인 연동 및 스플래시 스크린 간소화`

**Files:**
- Modified: `lib/features/auth/presentation/screens/login_screen.dart`
- Modified: `lib/features/auth/presentation/screens/splash_screen.dart`

**리뷰 포인트:**
- [ ] `login_screen.dart`: `ConsumerStatefulWidget` + try/catch 패턴 (ref.listen 아님)
- [ ] `login_screen.dart`: `_handleGoogleSignIn()` — await + catch + mounted 체크
- [ ] `login_screen.dart`: `_showLoginError()` — ref.read로 에러 메시지 추출 + AppSnackBar
- [ ] `login_screen.dart`: 버튼별 로딩 분기 (isGoogleLoading / isAppleLoading)
- [ ] `login_screen.dart`: Apple 버튼 iOS-only 조건 (`Platform.isIOS`)
- [ ] `splash_screen.dart`: StatefulWidget → StatelessWidget 전환, 네비게이션 로직 제거 (GoRouter가 처리)

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/features/auth/presentation/screens/login_screen.dart lib/features/auth/presentation/screens/splash_screen.dart
git commit -m "feat: 로그인 스크린 소셜 로그인 연동 및 스플래시 스크린 간소화"
```

---

## Task 7: GoRouter 인증 리다이렉트

**커밋 메시지:** `feat: GoRouter 인증 상태 기반 리다이렉트 추가`

**Files:**
- Modified: `lib/routes/app_router.dart`

**리뷰 포인트:**
- [ ] `RouterNotifier`: authNotifierProvider 구독 → GoRouter refresh 트리거
- [ ] `redirect` 로직: 로딩 중 → null (스플래시 유지), 미로그인 → /login, 로그인+인증화면 → /home
- [ ] `isAuthRoute` 판단: splash, login, onboarding
- [ ] 리다이렉트 무한 루프 방지 (login 화면에서 login으로 리다이렉트하지 않음)

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/routes/app_router.dart
git commit -m "feat: GoRouter 인증 상태 기반 리다이렉트 추가"
```

---

## Task 8: 프로필 로그아웃 버튼

**커밋 메시지:** `feat: 프로필 화면 로그아웃 버튼 추가`

**Files:**
- Modified: `lib/features/profile/presentation/screens/profile_screen.dart`

**리뷰 포인트:**
- [ ] `StatelessWidget` → `ConsumerWidget` 전환 (ref 접근 필요)
- [ ] 로그아웃 메뉴: `Icons.logout_rounded`, `AppColors.error` 색상, chevron 숨김
- [ ] `_buildMenuItem`: `iconColor`, `textColor`, `showChevron` 파라미터 추가
- [ ] 기존 "[테스트] 로그인 화면" 메뉴 제거

**Step 1: 리뷰 수행**

**Step 2: 커밋**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat: 프로필 화면 로그아웃 버튼 추가"
```

---

## Task 9 (선택): 계획 문서 커밋

**커밋 메시지:** `docs: Auth 구현 계획 문서 추가`

**Files:**
- New: `docs/plans/2026-02-11-auth-clean-architecture-refactor.md`
- New: `docs/plans/2026-02-11-springboot-api-spec.md`
- New: `docs/plans/2026-02-12-auth-files-integration.md`
- New: `docs/plans/2026-02-12-logout-flow-refactor.md`
- New: `docs/plans/2026-02-12-profile-logout-button.md`
- New: `docs/plans/2026-02-12-snackbar-error-try-catch-pattern.md`
- New: `docs/plans/2026-02-12-social-login-button-adaptation.md`
- New: `docs/plans/2026-02-12-social-login-per-button-loading.md`

**Step 1: 커밋**

```bash
git add docs/plans/
git commit -m "docs: Auth 구현 계획 문서 추가"
```

---

## 검증

모든 커밋 완료 후:
- [ ] `flutter analyze` — 정적 분석 통과
- [ ] `git log --oneline -10` — 커밋 순서 및 메시지 확인
- [ ] `git status` — clean working tree
