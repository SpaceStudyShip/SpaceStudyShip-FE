# 첫 로그인 isNewMember 기반 닉네임 설정화면 분기 — Design

**Date:** 2026-05-20
**Issue:** #71 follow-up (`issue/first-login-nickname-setup-branching.md`)
**Status:** Draft → Review

---

## 1. 배경 & 목적

소셜 로그인 응답의 `isNewMember` 플래그가 정의되어 있고 (`AuthResultEntity.isNewMember`, `SecureTokenStorage.saveIsNewMember/getIsNewMember`), 닉네임 변경/중복확인 API의 UseCase·Repository·DataSource 레이어도 모두 구현되어 있다. 그러나 현재 `GoRouter.redirect`는 신규/기존 회원을 구분하지 않고 동일한 흐름(`login → onboarding → home`)으로 라우팅한다.

본 작업의 목적은 **신규 회원에게만 닉네임 설정 화면을 강제로 노출**하고, **닉네임 변경 화면은 설정 메뉴에서도 재사용 가능한 공용 페이지**로 만드는 것이다.

### 비목적 (Out of Scope)
- 백엔드 API 변경 (현행 `/api/auth/nickname`, `/api/auth/check-nickname` 계약 그대로 사용).
- 게스트 모드의 닉네임 정책 변경. 게스트는 기존대로 닉네임 강제 없음.
- 기존 `OnboardingScreen` 위젯의 제거 또는 변형. 신규 흐름에서 분리만 한다.

---

## 2. 사용자 흐름

### 신규 회원 (isNewMember = true, isGuest = false)
```
앱 실행 → splash → login → 소셜 인증 성공
       → /nickname-setup (강제, 백버튼 없음)
       → 확인 → /home
```

### 기존 회원 (isNewMember = false)
```
앱 실행 → splash → login → 소셜 인증 성공 → /home
```

### 게스트 (isGuest = true)
```
앱 실행 → splash → login → "게스트로 시작하기" → /home
                                         (isNewMember 무시)
```

### 콜드스타트 — 닉네임 미완료 상태에서 앱 강제종료 후 재진입
```
앱 실행 → splash → AuthNotifier.build() 가 SecureTokenStorage 에서 복원
       → state.isNewMember = true → redirect → /nickname-setup 으로 자동 복귀
```

### 설정 메뉴에서 닉네임 변경 (자발적)
```
/profile/settings → "닉네임 변경" → /profile/settings/nickname-edit
                                  (AppBar 백버튼 있음)
                                  → 확인 또는 백버튼으로 종료 (pop)
```

---

## 3. 아키텍처

### 라우팅 분기 — Approach A (GoRouter redirect 단일 SSOT)

`app_router.dart` 의 `redirect` 함수 안에서 `isNewMember` 분기를 추가한다. 닉네임 설정 화면 진입/이탈/콜드스타트 복원이 모두 redirect 의 동일한 로직으로 처리되도록 한다.

```dart
redirect: (context, state) {
  final authState = ref.read(authNotifierProvider);
  final location = state.matchedLocation;
  final splashDone = ref.read(splashDelayProvider).hasValue;

  if (authState.isLoading || (location == RoutePaths.splash && !splashDone)) {
    return null;
  }

  final user = authState.valueOrNull;

  // 미로그인
  if (user == null) {
    return (location == RoutePaths.login) ? null : RoutePaths.login;
  }

  // 신규 회원(게스트 제외) → 닉네임 설정 강제
  final needsNicknameSetup = user.isNewMember && !user.isGuest;
  if (needsNicknameSetup) {
    return (location == RoutePaths.nicknameSetup) ? null : RoutePaths.nicknameSetup;
  }

  // 인증 흐름 화면에 머물러 있으면 home 으로
  if (location == RoutePaths.login ||
      location == RoutePaths.splash ||
      location == RoutePaths.nicknameSetup) {
    return RoutePaths.home;
  }

  return null;
}
```

> `RoutePaths.onboarding` 분기는 더 이상 자동 진입 대상이 아니다. 라우트는 보존하되 redirect 가 거치지 않는다.

### 닉네임 화면 — 공용 페이지 + mode 파라미터

```dart
enum NicknameMode {
  initialSetup,  // 신규 첫 로그인: 백버튼 없음, 완료 시 router 가 /home 으로 자동 이동
  edit,          // 설정 진입: 백버튼 있음, 완료 시 context.pop()
}
```

`/nickname-setup` 은 `initialSetup` 모드로 진입, `/profile/settings/nickname-edit` 는 `edit` 모드로 진입한다. 화면 위젯·폼 상태·검증·중복확인·제출 로직은 모두 동일하게 재사용된다.

### Provider 의존성

```
NicknameFormNotifier (신규)
  ├─ AuthRepository (기존)
  │    ├─ checkNickname(String) → bool
  │    └─ updateNickname(String) → String
  └─ AuthNotifier (기존, 메서드 1개 추가)
       └─ markNicknameConfirmed() [신규]
       └─ updateNickname(String)   [기존 — storage 동기화 추가]
```

---

## 4. 컴포넌트 명세

### 4.1 파일 변경 목록

```
lib/features/auth/presentation/
├── screens/
│   └── nickname_setup_screen.dart            [NEW]
├── widgets/
│   ├── nickname_input_field.dart             [NEW]
│   └── nickname_status_message.dart          [NEW]
└── providers/
    ├── nickname_form_provider.dart           [NEW]
    └── auth_provider.dart                    [EDIT — markNicknameConfirmed 추가, updateNickname storage 동기화]

lib/routes/
├── route_paths.dart                          [EDIT — nicknameSetup, nicknameEdit 경로 추가]
└── app_router.dart                           [EDIT — redirect 분기 + GoRoute 등록]

test/features/auth/presentation/
├── providers/
│   ├── nickname_form_provider_test.dart      [NEW]
│   └── auth_provider_test.dart               [EDIT or NEW — markNicknameConfirmed 테스트]
└── screens/
    └── nickname_setup_screen_test.dart       [NEW]

test/routes/
└── app_router_redirect_test.dart             [NEW or EDIT]
```

### 4.2 RoutePaths 추가

```dart
// lib/routes/route_paths.dart
static const nicknameSetup = '/nickname-setup';
static const nicknameEdit  = '/profile/settings/nickname-edit';
```

라우트 등록 위치:
- `nicknameSetup` → 인증 플로우 그룹(`splash`/`login`/`onboarding` 옆), ShellRoute **외부** GoRoute.
- `nicknameEdit` → Profile 탭 → `settings` 하위 GoRoute (`path: 'nickname-edit'`). ShellRoute **내부**. 즉:
  ```dart
  GoRoute(
    path: 'settings',
    name: 'settings',
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'nickname-edit',
        name: 'nicknameEdit',
        builder: (context, state) => const NicknameSetupScreen(mode: NicknameMode.edit),
      ),
    ],
  ),
  ```

### 4.3 NicknameFormState (Freezed)

```dart
@freezed
class NicknameFormState with _$NicknameFormState {
  const factory NicknameFormState({
    required String input,
    required String serverNickname,
    @Default(NicknameValidationStatus.idle) NicknameValidationStatus status,
    String? errorMessage,
    @Default(false) bool isCheckingDuplicate,
    @Default(false) bool isSubmitting,
  }) = _NicknameFormState;
}

enum NicknameValidationStatus {
  idle,            // input == serverNickname (진입 직후 또는 되돌림)
  invalidFormat,   // 정규식/길이 위반
  needsCheck,      // 형식 OK + input != serverNickname + 중복확인 미수행
  available,       // 중복확인 통과
  unavailable,     // 중복확인 실패 (또는 PATCH 시점 race)
}
```

### 4.4 NicknameFormNotifier (Riverpod, family)

```dart
@riverpod
class NicknameFormNotifier extends _$NicknameFormNotifier {
  @override
  NicknameFormState build(String serverNickname) =>
      NicknameFormState(input: serverNickname, serverNickname: serverNickname);

  void onInputChanged(String value);     // 상태 전이표(§5) 적용
  Future<void> checkDuplicate();         // CheckNicknameUseCase 호출
  Future<void> submit({required NicknameMode mode, ...});
}
```

`build` 인자로 `serverNickname` 을 받는 family — 화면 진입 시 `AuthNotifier.state.value.nickname` 으로 시드한다.

### 4.5 AuthNotifier 변경

```dart
// 신규 추가
Future<void> markNicknameConfirmed() async {
  final current = state.value;
  if (current == null || !current.isNewMember) return;  // no-op (멱등)
  state = AsyncValue.data(current.copyWith(isNewMember: false));
  // 콜드스타트 복원과 일관성 유지 — race 방지를 위해 await
  await ref.read(secureTokenStorageProvider).saveIsNewMember(false);
}

// 기존 updateNickname — storage 동기화 추가
Future<void> updateNickname(String nickname) async {
  final useCase = ref.read(updateNicknameUseCaseProvider);
  final newNickname = await useCase.execute(nickname);

  final current = state.value;
  if (current != null) {
    state = AsyncValue.data(
      current.copyWith(nickname: newNickname, isNewMember: false),
    );
    // [추가] storage 동기화 — 콜드스타트 시 다시 nickname 화면으로 가지 않도록
    await ref.read(secureTokenStorageProvider).saveIsNewMember(false);
  }
}
```

기존 `updateNicknameCompleted(String)` 은 호출처가 사실상 없으므로(현 검색 결과 기준) 보존하되 신규 코드는 `markNicknameConfirmed()` / `updateNickname()` 만 사용한다. 후속 정리는 본 spec 범위 밖.

### 4.6 NicknameSetupScreen 위젯 골격

```dart
class NicknameSetupScreen extends ConsumerWidget {
  final NicknameMode mode;
  const NicknameSetupScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial =
        ref.watch(authNotifierProvider).valueOrNull?.nickname ?? '';
    final form = ref.watch(nicknameFormNotifierProvider(initial));
    final notifier = ref.read(nicknameFormNotifierProvider(initial).notifier);

    return PopScope(
      canPop: mode == NicknameMode.edit,
      child: Scaffold(
        backgroundColor: AppColors.spaceBackground,
        appBar: mode == NicknameMode.edit
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('닉네임 변경',
                    style: AppTextStyles.subHeading_18
                        .copyWith(color: Colors.white)),
              )
            : null,
        body: Stack(children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Padding(
              padding: AppPadding.all20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (mode == NicknameMode.initialSetup) ...[
                  SizedBox(height: AppSpacing.s48),
                  Text('닉네임을 정해주세요',
                      style: AppTextStyles.heading_24
                          .copyWith(color: Colors.white)),
                  SizedBox(height: AppSpacing.s8),
                  Text('함께 우주를 탐험할 이름이에요',
                      style: AppTextStyles.paragraph_14
                          .copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.s32),
                ],
                NicknameInputField(
                  initialValue: initial,           // 진입 시점 서버 닉네임 시드 (controller text 초기값)
                  currentLength: form.input.length, // 카운터 표시용
                  onChanged: notifier.onInputChanged,
                  onCheckDuplicate: notifier.checkDuplicate,
                  status: form.status,
                  isCheckingDuplicate: form.isCheckingDuplicate,
                ),
                SizedBox(height: AppSpacing.s12),
                NicknameStatusMessage(
                  status: form.status,
                  errorMessage: form.errorMessage,
                ),
                const Spacer(),
                AppButton(
                  text: '확인',
                  isLoading: form.isSubmitting,
                  onPressed: _canSubmit(form.status) && !form.isSubmitting
                      ? () => notifier.submit(
                            mode: mode,
                            onCompleted: () {
                              if (mode == NicknameMode.edit) {
                                if (context.mounted) context.pop();
                              }
                              // initialSetup: router redirect 가 자동으로 /home 으로 이동
                            },
                          )
                      : null,
                  width: double.infinity,
                  height: 56.h,
                ),
                SizedBox(height: AppSpacing.s24),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  bool _canSubmit(NicknameValidationStatus s) =>
      s == NicknameValidationStatus.available ||
      s == NicknameValidationStatus.idle;
}
```

### 4.7 NicknameInputField 레이아웃

```
                                                    9/10  ← 카운터 (외부 Text)
┌──────────────────────────────────────┐  ┌─────────┐
│  민첩한괴도5308                       │  │ 중복확인 │
└──────────────────────────────────────┘  └─────────┘
   AppTextField (Expanded)                 OutlinedButton
   maxLength: 10
                                           (status == needsCheck 일 때만 활성)
```

- **레이아웃**: `Row(children: [Expanded(AppTextField), SizedBox(AppSpacing.s8), OutlinedButton])`.
- **카운터 표시**: `AppTextField` 는 내부적으로 `counterText: ''` 로 글자 수 카운터를 숨김 처리한다. 따라서 NicknameInputField 안에서 별도 `Text("${input.length}/10", style: AppTextStyles.tag_12)` 위젯을 입력 필드 우상단에 배치한다 (Row 위에 SizedBox + Align.right 로).
- **AppTextField props**: `controller: _controller`, `hintText: '닉네임'`, `maxLength: 10`, `onChanged: onChanged`.
- **OutlinedButton**: `onPressed: status == needsCheck ? onCheckDuplicate : null`. 활성/비활성/로딩 3-state 를 표현:
  - `isCheckingDuplicate=true` → `SizedBox(16×16) + CircularProgressIndicator(strokeWidth: 2)` 로 라벨 대체.
  - 그 외 → `Text("중복확인")` 또는 `available` 상태에서 `Text("사용가능")` (디자인 디테일).
- 우측 버튼은 `suffixIcon` 으로 넣지 않는다 — `AppTextField.suffixIcon` 은 작은 아이콘 영역 의도이며 텍스트 버튼은 시각적으로 비좁다.

---

## 5. 상태 전이표

| 현재 상태 | 트리거 | 다음 상태 | 중복확인 버튼 | 확인 버튼 | 메시지 |
|---|---|---|---|---|---|
| `idle` | 진입 | `idle` | 비활성 | **활성** | 메시지 없음 |
| `idle` | onInputChanged(v), v != server, 형식 OK | `needsCheck` | **활성** | 비활성 | "중복 확인을 해주세요" |
| `idle` | onInputChanged(v), 형식 위반 | `invalidFormat` | 비활성 | 비활성 | "2~10자, 한글/영문/숫자만 사용할 수 있어요" |
| `needsCheck` | onInputChanged(v), v == server | `idle` | 비활성 | **활성** | 메시지 없음 |
| `needsCheck` | checkDuplicate() → available=true | `available` | 비활성 ("사용가능") | **활성** | "사용 가능한 닉네임이에요" |
| `needsCheck` | checkDuplicate() → available=false | `unavailable` | 비활성 | 비활성 | "이미 사용 중인 닉네임이에요" |
| `available` | onInputChanged(v) (값 다시 변경) | needsCheck / idle / invalidFormat | 재평가 | 재평가 | 재평가 |
| `unavailable` | onInputChanged(v) | needsCheck / idle / invalidFormat | 재평가 | 재평가 | 재평가 |
| `invalidFormat` | onInputChanged(v) 형식 OK | needsCheck / idle | 재평가 | 재평가 | 재평가 |

### submit() 분기

`NicknameFormNotifier.submit({required NicknameMode mode, required VoidCallback onCompleted})`. `onCompleted` 콜백은 화면 위젯이 주입한다 — `initialSetup` 모드에서는 빈 콜백(router redirect 가 알아서 /home 으로 이동), `edit` 모드에서는 `() => context.pop()`.

```
submit(mode, onCompleted):
  if (status == idle):
    // 입력값 == 서버 닉네임 — PATCH 스킵
    if (mode == initialSetup):
      await AuthNotifier.markNicknameConfirmed()  // state.isNewMember=false → router redirect
    onCompleted()  // initialSetup 모드는 no-op, edit 모드는 pop
    return

  if (status == available):
    isSubmitting = true
    try:
      await AuthNotifier.updateNickname(input)
        // updateNickname() 내부에서 state.isNewMember=false 로 전환 + storage 동기화
      onCompleted()
    on InvalidInputValueException as e:
      status = invalidFormat
      errorMessage = e.message
    on DuplicatedNicknameException:
      status = unavailable
      errorMessage = "방금 다른 분이 사용하기 시작했어요. 다른 닉네임을 입력해주세요"
    on NetworkException / DioException:
      AppSnackBar.error("연결 상태를 확인해주세요")
    catch (_):
      AppSnackBar.error("잠시 후 다시 시도해주세요")
    finally:
      isSubmitting = false
```

> `edit` 모드 + `status == idle` 케이스: 사용자가 입력을 바꾸지 않고 확인만 누른 경우. `markNicknameConfirmed()` 는 isNewMember=false 인 사용자에게 no-op (멱등) → 그냥 `onCompleted()` → `context.pop()`. 의도된 동작.

---

## 6. 에러 처리

| 시나리오 | 사용자 표시 | UI 위치 |
|---|---|---|
| 형식 위반 (클라 사전 검증) | "2~10자, 한글/영문/숫자만 사용할 수 있어요" | NicknameStatusMessage |
| 형식 위반 — 서버 응답 `INVALID_INPUT_VALUE` | 서버 `message` 그대로 (금지어 등 동적 사유) | NicknameStatusMessage |
| 중복 — checkDuplicate available=false | "이미 사용 중인 닉네임이에요" | NicknameStatusMessage |
| 중복 — submit 시 race (`DuplicatedNicknameException`) | "방금 다른 분이 사용하기 시작했어요. 다른 닉네임을 입력해주세요" | NicknameStatusMessage + status=unavailable |
| 네트워크 에러 | "연결 상태를 확인해주세요" | AppSnackBar.error (입력값 유지) |
| 401 토큰 만료 | (forceLogout 콜백이 자동 처리) | 화면 자체가 /login 으로 |
| 5xx / 알 수 없는 에러 | "잠시 후 다시 시도해주세요" | AppSnackBar.error (입력값 유지) |

**디바운싱:** 형식 검증은 입력 변경마다 즉시 (클라이언트 로컬, 가벼움). 중복확인 API 호출은 **명시적 버튼 클릭으로만** 발생 — 자동 디바운스 호출 없음.

---

## 7. 콜드스타트 복원

기존 `AuthNotifier.build()` 가 `SecureTokenStorage.getIsNewMember()` 를 읽어 `AuthResultEntity.isNewMember` 를 복원한다. `markNicknameConfirmed()` / `updateNickname()` 성공 시 `saveIsNewMember(false)` 동기화가 추가되어 있으므로:

- 닉네임 설정 완료 후 앱 강제종료 → 재진입: storage `isNewMember=false` → `/home` 진입 정상.
- 닉네임 설정 미완료 상태 강제종료 → 재진입: storage `isNewMember=true` → redirect → `/nickname-setup` 복귀.

추가 코드 변경은 불필요.

---

## 8. 테스트 전략

### 8.1 단위 테스트
`test/features/auth/presentation/providers/nickname_form_provider_test.dart`

- 진입 직후 status=idle, input=serverNickname.
- 입력 변경 → status 전이 (idle / needsCheck / invalidFormat).
- 입력값을 서버 닉네임으로 되돌림 → status=idle.
- 1자, 11자, 특수문자, 이모지 → status=invalidFormat.
- checkDuplicate() 성공/실패/예외 → status 전이 + 메시지.
- available 상태에서 입력 변경 → status=needsCheck 으로 복귀.
- isCheckingDuplicate 플래그 토글.
- submit(idle) → AuthNotifier.markNicknameConfirmed 호출, updateNickname 호출 안 됨.
- submit(available) → AuthNotifier.updateNickname 호출.
- submit 중 DuplicatedNicknameException → status=unavailable.

### 8.2 AuthNotifier 단위 테스트
`test/features/auth/presentation/providers/auth_provider_test.dart`

- `markNicknameConfirmed()` (Future<void>): isNewMember=true 상태 → false 로 전환 + `saveIsNewMember(false)` await 호출 (mocktail verify).
- `markNicknameConfirmed()`: isNewMember=false 상태 → no-op (`saveIsNewMember` 호출 안 됨).
- `markNicknameConfirmed()`: state.value=null 상태 → no-op.
- `markNicknameConfirmed()`: storage write 실패 시 state 는 이미 전환되어 있고 예외만 전파 (현재 spec 은 throw 그대로 — 별도 catch 안 함).
- `updateNickname()` 성공: nickname/isNewMember 갱신 + `saveIsNewMember(false)` await 호출.

### 8.3 위젯 테스트
`test/features/auth/presentation/screens/nickname_setup_screen_test.dart`

- mode=initialSetup → AppBar 부재.
- mode=edit → AppBar 백버튼 존재.
- mode=initialSetup → PopScope.canPop=false.
- 진입 직후 확인 버튼 활성.
- 입력 변경 → 확인 비활성, 중복확인 활성.
- 중복확인 통과 → 확인 활성.
- 11자/특수문자 입력 → 에러 메시지 표시.
- 확인 클릭 → 적절한 AuthNotifier 메서드 호출 (mocktail verify).
- 네트워크 에러 → SnackBar 노출 (AppSnackBar mock).

### 8.4 Router redirect 테스트
`test/routes/app_router_redirect_test.dart`

| 케이스 | 초기 state | 진입 경로 | 기대 |
|---|---|---|---|
| 미로그인 | null | / | → /login |
| 신규 회원 로그인 직후 | isNewMember=true, isGuest=false | /login 성공 후 평가 | → /nickname-setup |
| 신규 회원 우회 시도 | isNewMember=true | /home | → /nickname-setup |
| 닉네임 완료 전이 | isNewMember false 로 변경 | /nickname-setup | → /home |
| 기존 회원 | isNewMember=false | /login 성공 후 평가 | → /home |
| 게스트 + isNewMember=true (이상 케이스) | isGuest=true, isNewMember=true | /login 성공 후 평가 | → /home (isNewMember 무시) |
| 콜드스타트 미완료 복원 | storage isNewMember=true 로 build() | / | → /nickname-setup |

### 8.5 수동 검증
실기기(iOS/Android)에서 시연:
1. 신규 회원 로그인 → 닉네임 설정 화면 강제 노출, 백버튼 차단.
2. 기존 회원 로그인 → /home 직행.
3. 닉네임 미완료 상태에서 앱 강제종료 → 재진입 시 닉네임 화면 복귀.
4. 게스트 로그인 → 닉네임 강제 없음, /home 직행.
5. 설정 메뉴 → 닉네임 변경 → 백버튼 동작, 확인 시 변경 반영.

`flutter analyze` 경고 0, 기존 router/auth 테스트 모두 통과 유지.

---

## 9. 디자인 시스템 준수

- `AppColors.spaceBackground`, `SpaceBackground` 위젯 사용 (모든 화면 필수).
- `AppSpacing.s8/s12/s16/s20/s24/s32/s48` 만 사용 (s10/s14 등 금지).
- `AppPadding.all20`, `AppPadding.horizontal20` 사용.
- 텍스트는 `AppTextStyles.heading_24` / `subHeading_18` / `paragraph_14` 사용.
- 이모지 금지. 아이콘은 Material `Icons.xxx` 또는 `FaIcon`.
- 닉네임 입력은 `AppTextField` 활용, 우측 버튼은 `OutlinedButton` 또는 `AppButton` 스타일.
- 확인 버튼은 `AppButton` (기존 패턴).

---

## 10. 가정 & 미확정 항목

- **서버는 신규 가입 시 부여한 랜덤 닉네임을 해당 회원 본인의 닉네임으로 등록한 상태**라고 가정 (입력값을 그대로 두고 확인만 눌러도 PATCH 호출 없이 isNewMember=false 전환). 백엔드와 한 번 더 확인 권장. 만약 서버가 닉네임 "확정" 신호를 명시적으로 요구한다면 PATCH 분기 정책을 변경 (`submit(idle)` 에서도 PATCH 호출).
- 설정 메뉴 진입점(`/profile/settings/nickname-edit` 진입 트리거 UI) 자체의 구현은 본 spec 범위 — 공용 화면이 존재하면 설정 화면에서 `context.push(RoutePaths.nicknameEdit)` 만 호출하면 된다.
- 게스트가 어떤 경로로든 `/nickname-setup` URL 에 직접 도달하는 시나리오는 redirect 가 `/home` 으로 튕긴다. 별도 가드 불필요.

---

## 11. 변경 영향 범위

- `app_router.dart` redirect 분기 — 기존 `RoutePaths.onboarding` 자동 진입 흐름이 사라진다. 신규 로그인 사용자가 OnboardingScreen 튜토리얼을 더 이상 보지 않는다.
- `AuthNotifier.updateNickname()` 의 부수효과로 `saveIsNewMember(false)` 가 추가된다. 호출처가 (현재) 사실상 없지만, 향후 닉네임 변경 화면이 동작하기 시작하면 효과가 생긴다.
- 신규 화면/위젯/프로바이더 추가, 외부 의존성 변경 없음.

---

## 12. 후속 작업 (별도 spec/이슈)

- 설정 메뉴에 "닉네임 변경" 진입 트리거 추가 (UI 위치/디자인 결정).
- 기존 `updateNicknameCompleted(String)` 메서드 deprecate 또는 정리.
- 신규 회원 가입 직후 추후 튜토리얼(`OnboardingScreen`) 을 어디서, 어떻게 다시 노출할지 — 가벼운 진입점(예: 프로필 메뉴) 또는 제거 결정.
