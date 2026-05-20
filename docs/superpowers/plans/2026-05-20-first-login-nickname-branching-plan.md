# 첫 로그인 isNewMember 기반 닉네임 설정화면 분기 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 소셜 로그인 후 `isNewMember=true` 인 신규 회원에게 닉네임 설정 화면을 강제 노출하고, 동일한 화면을 설정 메뉴의 닉네임 변경 진입점으로도 재사용한다.

**Architecture:** `GoRouter.redirect` 안에 `isNewMember` 분기를 추가해 라우팅 SSOT 를 유지한다. 닉네임 화면은 단일 위젯에 `NicknameMode { initialSetup, edit }` 파라미터를 받아 두 컨텍스트(강제 흐름 vs 자발적 변경)를 흡수한다. 폼 상태머신은 `NicknameFormNotifier` 가 관리하며, 형식검증→중복확인→제출 3단 흐름을 명시적 enum 상태로 표현한다.

**Tech Stack:** Flutter 3.9 · Riverpod 2.6 (+ generator) · Freezed 2.5 · GoRouter 17 · mocktail 1.0. 기존 `AppTextField`/`AppButton`/`AppSnackBar`/`SpaceBackground` 디자인 시스템 활용.

**Spec:** [`docs/superpowers/specs/2026-05-20-first-login-nickname-branching-design.md`](../specs/2026-05-20-first-login-nickname-branching-design.md)

**Issue:** #75 (브랜치 `20260519_#75_첫_로그인_시_닉네임_설정화면_분기`)

---

## File Structure

| 파일 | 변경 | 책임 |
|---|---|---|
| `lib/routes/route_paths.dart` | EDIT | 인증 플로우에 `nicknameSetup`, `nicknameEdit` 경로 상수 추가 |
| `lib/routes/app_router.dart` | EDIT | redirect 분기에 `isNewMember` 처리 + 2개 GoRoute 등록 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | EDIT | `markNicknameConfirmed()` 추가, `updateNickname()` storage 동기화 |
| `lib/features/auth/presentation/providers/nickname_form_provider.dart` | NEW | `NicknameValidationStatus` enum, `NicknameFormState`, `NicknameFormNotifier` (family) |
| `lib/features/auth/presentation/screens/nickname_setup_screen.dart` | NEW | `NicknameMode` enum + 공용 닉네임 설정/변경 화면 |
| `lib/features/auth/presentation/widgets/nickname_input_field.dart` | NEW | AppTextField + 우측 중복확인 OutlinedButton + 외부 카운터 |
| `lib/features/auth/presentation/widgets/nickname_status_message.dart` | NEW | 형식/중복확인 상태별 메시지 표시 |
| `test/features/auth/presentation/providers/auth_provider_test.dart` | NEW | `markNicknameConfirmed`, `updateNickname` storage 동기화 검증 |
| `test/features/auth/presentation/providers/nickname_form_provider_test.dart` | NEW | 상태머신/중복확인/submit 단위 테스트 |
| `test/features/auth/presentation/screens/nickname_setup_screen_test.dart` | NEW | mode별 AppBar/PopScope/버튼 활성 검증 |
| `test/routes/app_router_redirect_test.dart` | NEW | 신규/기존/게스트/콜드스타트 redirect 시나리오 검증 |

---

## 실행 사전 준비 (모든 Task 공통)

각 Task 시작 전:

```bash
cd /Users/luca/workspace/Flutter_Project/space_study_ship
git status            # clean 인지 확인
```

코드 생성이 필요한 Task 후:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

각 Task 종료 직전:

```bash
flutter analyze                       # 경고 0 확인
flutter test <해당 테스트 경로>       # 통과 확인
```

커밋 메시지 형식: `<type> : <한글 설명> #75`. `Co-Authored-By` 절대 금지. 이모지 금지.

---

## Phase 1 — 라우팅 분기 기반

### Task 1: RoutePaths 상수 추가

**Files:**
- Modify: `lib/routes/route_paths.dart`

- [ ] **Step 1: 인증 플로우 그룹에 nicknameSetup 추가**

`lib/routes/route_paths.dart` 의 "인증 플로우" 섹션 끝에 한 줄 추가:

```dart
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const nicknameSetup = '/nickname-setup';   // 추가
```

- [ ] **Step 2: Profile 하위 화면 그룹에 nicknameEdit 추가**

같은 파일의 "Profile 하위 화면" 섹션 안 `settings` 라인 아래에 한 줄 추가:

```dart
  static const settings = '/profile/settings';
  static const nicknameEdit = '/profile/settings/nickname-edit';   // 추가
  static const badges = '/profile/badges';
```

- [ ] **Step 3: 컴파일 확인**

```bash
flutter analyze lib/routes/route_paths.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/routes/route_paths.dart
git commit -m "feat : 닉네임 설정/변경 라우트 상수 #75"
```

---

### Task 2: AuthNotifier에 markNicknameConfirmed 추가 (RED→GREEN)

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`
- Test: `test/features/auth/presentation/providers/auth_provider_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/features/auth/presentation/providers/auth_provider_test.dart` (신규):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late _MockTokenStorage tokenStorage;
  late ProviderContainer container;

  setUp(() {
    tokenStorage = _MockTokenStorage();
    when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        secureTokenStorageProvider.overrideWithValue(tokenStorage),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('markNicknameConfirmed', () {
    test('isNewMember=true 상태 → false 로 전환 + saveIsNewMember(false) 호출', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: true),
      );

      await notifier.markNicknameConfirmed();

      expect(container.read(authNotifierProvider).value!.isNewMember, isFalse);
      expect(container.read(authNotifierProvider).value!.nickname, 'abc');
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
    });

    test('isNewMember=false 상태 → no-op (storage 호출 없음)', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: false),
      );

      await notifier.markNicknameConfirmed();

      verifyNever(() => tokenStorage.saveIsNewMember(any()));
    });

    test('state.value=null 상태 → no-op', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(null);

      await notifier.markNicknameConfirmed();

      verifyNever(() => tokenStorage.saveIsNewMember(any()));
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/auth/presentation/providers/auth_provider_test.dart
```

Expected: FAIL — `The method 'markNicknameConfirmed' isn't defined`

- [ ] **Step 3: AuthNotifier 에 메서드 추가**

`lib/features/auth/presentation/providers/auth_provider.dart` 의 `AuthNotifier` 클래스 안, `forceLogout()` 메서드 위에 추가:

```dart
  /// 닉네임 설정 완료 신호 — 입력값이 진입 시점 서버 닉네임과 동일해
  /// PATCH 호출을 스킵하는 경우 사용. isNewMember 만 false 로 전환하고
  /// SecureTokenStorage 와 동기화한다 (콜드스타트 복원 일관성).
  Future<void> markNicknameConfirmed() async {
    final current = state.value;
    if (current == null || !current.isNewMember) return;
    state = AsyncValue.data(current.copyWith(isNewMember: false));
    await ref.read(secureTokenStorageProvider).saveIsNewMember(false);
  }
```

- [ ] **Step 4: 코드 생성 (Riverpod generator)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

(이번 task 는 새 provider 추가가 없으므로 사실상 no-op. 안전상 한 번 실행.)

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/auth/presentation/providers/auth_provider_test.dart
```

Expected: PASS — 3 tests

- [ ] **Step 6: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart \
        test/features/auth/presentation/providers/auth_provider_test.dart
git commit -m "feat : AuthNotifier.markNicknameConfirmed 추가 #75"
```

---

### Task 3: AuthNotifier.updateNickname 에 storage 동기화 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`
- Modify: `test/features/auth/presentation/providers/auth_provider_test.dart`

- [ ] **Step 1: 실패 테스트 추가**

`test/features/auth/presentation/providers/auth_provider_test.dart` 의 `main()` 끝에 group 추가:

```dart
  group('updateNickname storage sync', () {
    test('성공 시 saveIsNewMember(false) await 호출', () async {
      // updateNicknameUseCaseProvider 를 override 해 가짜 결과 반환
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'old', isNewMember: true),
      );

      // 직접 호출 대신 state 변화 + storage 호출만 검증.
      // (UseCase mock 은 통합 부담이라 spec 의 명세를 따라 storage 호출 시점만 확인.)
      // → 이 테스트는 실제 호출 검증이 어려우므로 Task 9 (submit) 의 통합 테스트로 대체.
    }, skip: 'Task 9 의 NicknameFormNotifier.submit 통합 테스트에서 검증');
  });
```

> 이 group 은 placeholder. updateNickname 의 storage 동기화는 호출 체인이 길어 단위 테스트가 부담 — Phase 3 Task 9 의 `submit(available)` 케이스에서 `verify(() => tokenStorage.saveIsNewMember(false)).called(1)` 로 통합 검증한다.

- [ ] **Step 2: updateNickname 수정**

`lib/features/auth/presentation/providers/auth_provider.dart` 의 기존 `updateNickname` 메서드 본문을 교체:

```dart
  /// 닉네임 변경
  ///
  /// 성공 시 현재 상태의 nickname 갱신, isNewMember=false 처리,
  /// SecureTokenStorage 도 동기화한다.
  Future<void> updateNickname(String nickname) async {
    final useCase = ref.read(updateNicknameUseCaseProvider);
    final newNickname = await useCase.execute(nickname);

    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(nickname: newNickname, isNewMember: false),
      );
      await ref.read(secureTokenStorageProvider).saveIsNewMember(false);
    }
  }
```

- [ ] **Step 3: 기존 테스트 통과 확인 (회귀 없음)**

```bash
flutter test test/features/auth/
```

Expected: 모든 기존 auth 테스트 PASS (markNicknameConfirmed 포함)

- [ ] **Step 4: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart \
        test/features/auth/presentation/providers/auth_provider_test.dart
git commit -m "feat : updateNickname storage 동기화 #75"
```

---

## Phase 2 — Nickname Form 상태머신

### Task 4: NicknameValidationStatus enum + NicknameFormState 정의

**Files:**
- Create: `lib/features/auth/presentation/providers/nickname_form_provider.dart`

- [ ] **Step 1: 파일 신규 생성 (상태 정의만)**

`lib/features/auth/presentation/providers/nickname_form_provider.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nickname_form_provider.freezed.dart';
part 'nickname_form_provider.g.dart';

/// 닉네임 입력 폼의 검증 상태.
enum NicknameValidationStatus {
  /// 입력값 == 진입 시점 서버 닉네임 (변경 없음).
  idle,

  /// 정규식 또는 길이 위반.
  invalidFormat,

  /// 형식 OK + 입력값 != 서버 닉네임 + 중복확인 미수행.
  needsCheck,

  /// 중복확인 통과.
  available,

  /// 중복확인 실패 또는 PATCH 시점 race.
  unavailable,
}

/// 닉네임 입력 폼 상태.
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
```

- [ ] **Step 2: 코드 생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `nickname_form_provider.freezed.dart`, `nickname_form_provider.g.dart` 생성

- [ ] **Step 3: Analyze**

```bash
flutter analyze lib/features/auth/presentation/providers/nickname_form_provider.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/providers/nickname_form_provider.dart \
        lib/features/auth/presentation/providers/nickname_form_provider.freezed.dart \
        lib/features/auth/presentation/providers/nickname_form_provider.g.dart
git commit -m "feat : NicknameFormState/Status 정의 #75"
```

---

### Task 5: NicknameFormNotifier.onInputChanged 상태 전이 (TDD)

**Files:**
- Modify: `lib/features/auth/presentation/providers/nickname_form_provider.dart`
- Create: `test/features/auth/presentation/providers/nickname_form_provider_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/features/auth/presentation/providers/nickname_form_provider_test.dart` (신규):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_study_ship/features/auth/presentation/providers/nickname_form_provider.dart';

void main() {
  ProviderContainer makeContainer(String serverNickname) {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    // family provider warm-up
    c.read(nicknameFormNotifierProvider(serverNickname));
    return c;
  }

  group('build() 진입 직후', () {
    test('input=serverNickname, status=idle', () {
      final c = makeContainer('민첩한괴도5308');
      final s = c.read(nicknameFormNotifierProvider('민첩한괴도5308'));
      expect(s.input, '민첩한괴도5308');
      expect(s.serverNickname, '민첩한괴도5308');
      expect(s.status, NicknameValidationStatus.idle);
    });
  });

  group('onInputChanged 상태 전이', () {
    test('입력 변경 (다른 유효 값) → needsCheck', () {
      final c = makeContainer('abc12');
      c.read(nicknameFormNotifierProvider('abc12').notifier)
          .onInputChanged('우주탐험가');
      final s = c.read(nicknameFormNotifierProvider('abc12'));
      expect(s.status, NicknameValidationStatus.needsCheck);
      expect(s.errorMessage, isNotNull);   // "중복 확인을 해주세요"
    });

    test('입력값을 서버 닉네임으로 되돌림 → idle', () {
      final n = makeContainer('abc12').read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      n.onInputChanged('abc12');
      expect(
        n.state.status,
        NicknameValidationStatus.idle,
      );
    });

    test('1자 입력 → invalidFormat', () {
      final n = makeContainer('abc12').read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('11자 입력 → invalidFormat', () {
      final n = makeContainer('abc12').read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가12345678');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('특수문자 포함 → invalidFormat', () {
      final n = makeContainer('abc12').read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주@');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('이모지 포함 → invalidFormat', () {
      final n = makeContainer('abc12').read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주\u{1F680}');   // 🚀
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: FAIL — `nicknameFormNotifierProvider` 정의 없음

- [ ] **Step 3: NicknameFormNotifier 구현**

`lib/features/auth/presentation/providers/nickname_form_provider.dart` 끝에 추가:

```dart
/// 닉네임 정규식 (UseCase 와 동일 규칙).
final RegExp _kNicknamePattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
const int _kNicknameMinLength = 2;
const int _kNicknameMaxLength = 10;

@riverpod
class NicknameFormNotifier extends _$NicknameFormNotifier {
  @override
  NicknameFormState build(String serverNickname) {
    return NicknameFormState(
      input: serverNickname,
      serverNickname: serverNickname,
      status: NicknameValidationStatus.idle,
    );
  }

  void onInputChanged(String value) {
    final trimmed = value;
    // 1) 진입 닉네임과 동일하면 idle
    if (trimmed == state.serverNickname) {
      state = state.copyWith(
        input: trimmed,
        status: NicknameValidationStatus.idle,
        errorMessage: null,
      );
      return;
    }
    // 2) 형식 검증
    if (trimmed.length < _kNicknameMinLength ||
        trimmed.length > _kNicknameMaxLength ||
        !_kNicknamePattern.hasMatch(trimmed)) {
      state = state.copyWith(
        input: trimmed,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: '2~10자, 한글/영문/숫자만 사용할 수 있어요',
      );
      return;
    }
    // 3) 형식 OK → 중복확인 필요
    state = state.copyWith(
      input: trimmed,
      status: NicknameValidationStatus.needsCheck,
      errorMessage: '중복 확인을 해주세요',
    );
  }
}
```

- [ ] **Step 4: 코드 생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: PASS — 7 tests

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/providers/nickname_form_provider.dart \
        lib/features/auth/presentation/providers/nickname_form_provider.g.dart \
        test/features/auth/presentation/providers/nickname_form_provider_test.dart
git commit -m "feat : NicknameFormNotifier 입력 상태전이 #75"
```

---

### Task 6: NicknameFormNotifier.checkDuplicate (TDD)

**Files:**
- Modify: `lib/features/auth/presentation/providers/nickname_form_provider.dart`
- Modify: `test/features/auth/presentation/providers/nickname_form_provider_test.dart`

- [ ] **Step 1: 실패 테스트 추가 (test 파일 끝에)**

```dart
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  // ... 기존 group 들 유지 ...

  group('checkDuplicate', () {
    late _MockAuthRepo repo;
    late ProviderContainer container;

    setUp(() {
      repo = _MockAuthRepo();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
    });

    test('available=true → status=available', () async {
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.available);
      expect(n.state.isCheckingDuplicate, isFalse);
    });

    test('available=false → status=unavailable', () async {
      when(() => repo.checkNickname('taken')).thenAnswer((_) async => false);
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('taken');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.unavailable);
    });

    test('InvalidInputValueException → status=invalidFormat', () async {
      when(() => repo.checkNickname(any())).thenThrow(
        const InvalidInputValueException(message: '금지어'),
      );
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('욕설');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
      expect(n.state.errorMessage, '금지어');
    });

    test('isCheckingDuplicate 플래그 토글', () async {
      when(() => repo.checkNickname(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return true;
      });
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      final future = n.checkDuplicate();
      expect(n.state.isCheckingDuplicate, isTrue);
      await future;
      expect(n.state.isCheckingDuplicate, isFalse);
    });
  });
}
```

> 기존 `main()` 함수에 위 group 만 추가. import 도 함께 추가.

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: FAIL — `checkDuplicate` 정의 없음

- [ ] **Step 3: checkDuplicate 구현**

`lib/features/auth/presentation/providers/nickname_form_provider.dart` 의 `NicknameFormNotifier` 안에 추가:

```dart
  /// 명시적 버튼 클릭으로만 호출. status=needsCheck 가 아니면 no-op.
  Future<void> checkDuplicate() async {
    if (state.status != NicknameValidationStatus.needsCheck) return;
    state = state.copyWith(isCheckingDuplicate: true);
    try {
      final available =
          await ref.read(authRepositoryProvider).checkNickname(state.input);
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: available
            ? NicknameValidationStatus.available
            : NicknameValidationStatus.unavailable,
        errorMessage: available
            ? '사용 가능한 닉네임이에요'
            : '이미 사용 중인 닉네임이에요',
      );
    } on InvalidInputValueException catch (e) {
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: e.message,
      );
    } catch (_) {
      // 네트워크/기타 — 상태는 needsCheck 로 복원, 메시지만 갱신
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: NicknameValidationStatus.needsCheck,
        errorMessage: '확인에 실패했어요. 잠시 후 다시 시도해주세요',
      );
    }
  }
```

추가 import 가 필요:

```dart
import '../../../../core/errors/app_exception.dart';
import 'auth_provider.dart';
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: PASS — 11 tests (기존 7 + 신규 4)

- [ ] **Step 5: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/providers/nickname_form_provider.dart \
        test/features/auth/presentation/providers/nickname_form_provider_test.dart
git commit -m "feat : NicknameFormNotifier checkDuplicate #75"
```

---

### Task 7: NicknameFormNotifier.submit (TDD)

**Files:**
- Modify: `lib/features/auth/presentation/providers/nickname_form_provider.dart`
- Modify: `test/features/auth/presentation/providers/nickname_form_provider_test.dart`

- [ ] **Step 1: 실패 테스트 추가**

테스트 파일 끝에 group 추가:

```dart
  group('submit', () {
    late _MockAuthRepo repo;
    late _MockTokenStorage tokenStorage;
    late ProviderContainer container;

    setUp(() {
      repo = _MockAuthRepo();
      tokenStorage = _MockTokenStorage();
      when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          secureTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      addTearDown(container.dispose);
    });

    test('status=idle, mode=initialSetup → markNicknameConfirmed 호출 + onCompleted', () async {
      final auth = container.read(authNotifierProvider.notifier);
      auth.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
      );
      var completed = false;

      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () => completed = true,
      );

      expect(completed, isTrue);
      expect(container.read(authNotifierProvider).value!.isNewMember, isFalse);
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      verifyNever(() => repo.updateNickname(any()));
    });

    test('status=available → updateNickname 호출 + onCompleted', () async {
      when(() => repo.updateNickname('우주탐험가'))
          .thenAnswer((_) async => '우주탐험가');
      final auth = container.read(authNotifierProvider.notifier);
      auth.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
      );

      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      // available 상태로 진입
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.available);

      var completed = false;
      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () => completed = true,
      );

      expect(completed, isTrue);
      verify(() => repo.updateNickname('우주탐험가')).called(1);
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      expect(container.read(authNotifierProvider).value!.nickname, '우주탐험가');
    });

    test('submit 중 DuplicatedNicknameException → status=unavailable', () async {
      when(() => repo.updateNickname(any()))
          .thenThrow(const DuplicatedNicknameException());
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      await n.submit(mode: NicknameMode.initialSetup, onCompleted: () {});

      expect(n.state.status, NicknameValidationStatus.unavailable);
      expect(n.state.errorMessage, contains('다른 분이'));
    });

    test('submit 중 InvalidInputValueException → status=invalidFormat', () async {
      when(() => repo.updateNickname(any())).thenThrow(
        const InvalidInputValueException(message: '금지어'),
      );
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      await n.submit(mode: NicknameMode.initialSetup, onCompleted: () {});

      expect(n.state.status, NicknameValidationStatus.invalidFormat);
      expect(n.state.errorMessage, '금지어');
    });

    test('isSubmitting 토글', () async {
      when(() => repo.updateNickname(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'x';
      });
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      final future = n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () {},
      );
      expect(n.state.isSubmitting, isTrue);
      await future;
      expect(n.state.isSubmitting, isFalse);
    });
  });
```

> 추가 import 가 필요:
> ```dart
> import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
> import 'package:space_study_ship/features/auth/presentation/screens/nickname_setup_screen.dart';   // NicknameMode
> ```
> `NicknameMode` 는 다음 Phase 의 화면 파일에 정의되지만 enum 만 미리 노출시키기 위해, Phase 3 시작 전 다음 Task 9 (Screen) 단계에서 enum 을 별도 파일로 분리하지 않고 같은 파일 안 import 가 가능하도록 `nickname_setup_screen.dart` 를 Task 7 직전에 만들어둔다 — 아래 Step 2 참고.

- [ ] **Step 2: NicknameMode enum 만 미리 정의**

`lib/features/auth/presentation/screens/nickname_setup_screen.dart` 신규 생성:

```dart
/// 닉네임 화면 진입 컨텍스트. 본 화면 구현은 Task 11 에서 채운다.
enum NicknameMode {
  /// 신규 회원 첫 로그인: 백버튼 차단, 완료 시 router redirect 가 /home 으로.
  initialSetup,

  /// 설정 메뉴 자발적 변경: 백버튼 있음, 완료 시 context.pop().
  edit,
}
```

> 화면 위젯은 Task 11 에서 채운다. enum 만 먼저 분리해 Provider 가 import 가능하게.

- [ ] **Step 3: 테스트 실패 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: FAIL — `submit` 정의 없음

- [ ] **Step 4: submit 구현**

`lib/features/auth/presentation/providers/nickname_form_provider.dart` 상단 import 에 추가:

```dart
import '../screens/nickname_setup_screen.dart';
```

`NicknameFormNotifier` 안에 추가:

```dart
  /// 확인 버튼 클릭. status 가 idle 또는 available 일 때만 의미 있음.
  /// onCompleted 는 mode 별 후처리(예: edit 모드 pop) 콜백.
  Future<void> submit({
    required NicknameMode mode,
    required void Function() onCompleted,
  }) async {
    // 1) 입력값 == 서버 닉네임 — PATCH 스킵
    if (state.status == NicknameValidationStatus.idle) {
      if (mode == NicknameMode.initialSetup) {
        await ref.read(authNotifierProvider.notifier).markNicknameConfirmed();
      }
      onCompleted();
      return;
    }

    // 2) 중복확인 통과 — PATCH 호출
    if (state.status != NicknameValidationStatus.available) return;

    state = state.copyWith(isSubmitting: true);
    try {
      await ref.read(authNotifierProvider.notifier).updateNickname(state.input);
      state = state.copyWith(isSubmitting: false);
      onCompleted();
    } on DuplicatedNicknameException {
      state = state.copyWith(
        isSubmitting: false,
        status: NicknameValidationStatus.unavailable,
        errorMessage: '방금 다른 분이 사용하기 시작했어요. 다른 닉네임을 입력해주세요',
      );
    } on InvalidInputValueException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      // SnackBar 노출은 화면 위젯에서 form.errorMessage 또는 별도 콜백으로 처리.
      // 여기서는 status 는 available 유지(사용자가 재시도 가능하도록).
    }
  }
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/auth/presentation/providers/nickname_form_provider_test.dart
```

Expected: PASS — 16 tests (기존 11 + 신규 5)

- [ ] **Step 6: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/presentation/providers/nickname_form_provider.dart \
        lib/features/auth/presentation/screens/nickname_setup_screen.dart \
        test/features/auth/presentation/providers/nickname_form_provider_test.dart
git commit -m "feat : NicknameFormNotifier submit + NicknameMode #75"
```

---

## Phase 3 — UI 위젯

### Task 8: NicknameInputField 위젯

**Files:**
- Create: `lib/features/auth/presentation/widgets/nickname_input_field.dart`

> 위젯 구조는 단순 stateless. 별도 단위 테스트는 Task 11 의 NicknameSetupScreen 위젯 테스트에서 통합으로 검증.

- [ ] **Step 1: 위젯 작성**

`lib/features/auth/presentation/widgets/nickname_input_field.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../providers/nickname_form_provider.dart';

/// 닉네임 입력 + 우측 중복확인 버튼 + 우상단 카운터.
///
/// 상위 위젯은 [NicknameFormState] 를 구독하여 상태와 콜백을 주입한다.
class NicknameInputField extends StatefulWidget {
  const NicknameInputField({
    super.key,
    required this.initialValue,
    required this.currentLength,
    required this.status,
    required this.isCheckingDuplicate,
    required this.onChanged,
    required this.onCheckDuplicate,
  });

  /// 진입 시점 서버 닉네임 (TextField 초기값).
  final String initialValue;

  /// 현재 입력 글자 수 (카운터 표시용).
  final int currentLength;

  final NicknameValidationStatus status;
  final bool isCheckingDuplicate;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheckDuplicate;

  @override
  State<NicknameInputField> createState() => _NicknameInputFieldState();
}

class _NicknameInputFieldState extends State<NicknameInputField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canCheckDuplicate =>
      widget.status == NicknameValidationStatus.needsCheck &&
      !widget.isCheckingDuplicate;

  String get _buttonLabel {
    if (widget.status == NicknameValidationStatus.available) return '사용가능';
    return '중복확인';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 카운터 (우상단)
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s4),
          child: Text(
            '${widget.currentLength}/10',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        // 입력 + 우측 버튼
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hintText: '닉네임',
                maxLength: 10,
                onChanged: widget.onChanged,
              ),
            ),
            SizedBox(width: AppSpacing.s8),
            OutlinedButton(
              onPressed: _canCheckDuplicate ? widget.onCheckDuplicate : null,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(80.w, 56.h),
                side: BorderSide(
                  color: _canCheckDuplicate
                      ? AppColors.primary
                      : AppColors.spaceDivider,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.large,
                ),
              ),
              child: widget.isCheckingDuplicate
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Text(
                      _buttonLabel,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: _canCheckDuplicate
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/features/auth/presentation/widgets/nickname_input_field.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/widgets/nickname_input_field.dart
git commit -m "feat : NicknameInputField 위젯 #75"
```

---

### Task 9: NicknameStatusMessage 위젯

**Files:**
- Create: `lib/features/auth/presentation/widgets/nickname_status_message.dart`

- [ ] **Step 1: 위젯 작성**

`lib/features/auth/presentation/widgets/nickname_status_message.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/nickname_form_provider.dart';

/// 닉네임 폼 status 별 안내/에러 메시지를 표시한다.
/// errorMessage 가 비어 있고 status 가 idle 이면 빈 영역(공간 보존).
class NicknameStatusMessage extends StatelessWidget {
  const NicknameStatusMessage({
    super.key,
    required this.status,
    required this.errorMessage,
  });

  final NicknameValidationStatus status;
  final String? errorMessage;

  Color _color() {
    switch (status) {
      case NicknameValidationStatus.available:
        return AppColors.success;
      case NicknameValidationStatus.invalidFormat:
      case NicknameValidationStatus.unavailable:
        return AppColors.error;
      case NicknameValidationStatus.needsCheck:
        return AppColors.textSecondary;
      case NicknameValidationStatus.idle:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = errorMessage ?? '';
    return SizedBox(
      height: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTextStyles.tag_12.copyWith(color: _color()),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/features/auth/presentation/widgets/nickname_status_message.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/widgets/nickname_status_message.dart
git commit -m "feat : NicknameStatusMessage 위젯 #75"
```

---

### Task 10: NicknameSetupScreen 본 구현 (TDD: 위젯 테스트)

**Files:**
- Modify: `lib/features/auth/presentation/screens/nickname_setup_screen.dart`
- Create: `test/features/auth/presentation/screens/nickname_setup_screen_test.dart`

- [ ] **Step 1: 실패하는 위젯 테스트 작성**

`test/features/auth/presentation/screens/nickname_setup_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/auth/presentation/screens/nickname_setup_screen.dart';

class _MockRepo extends Mock implements AuthRepository {}
class _MockTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late _MockRepo repo;
  late _MockTokenStorage tokenStorage;

  setUp(() {
    repo = _MockRepo();
    tokenStorage = _MockTokenStorage();
    when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
  });

  Widget makeApp(NicknameMode mode, AuthResultEntity user) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        secureTokenStorageProvider.overrideWithValue(tokenStorage),
        authNotifierProvider.overrideWith(() {
          final n = AuthNotifier();
          n.state = AsyncValue.data(user);
          return n;
        }),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          home: NicknameSetupScreen(mode: mode),
        ),
      ),
    );
  }

  testWidgets('mode=initialSetup → AppBar 없음', (tester) async {
    await tester.pumpWidget(makeApp(
      NicknameMode.initialSetup,
      const AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
    ));
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('mode=edit → AppBar 와 백버튼 존재', (tester) async {
    await tester.pumpWidget(makeApp(
      NicknameMode.edit,
      const AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: false),
    ));
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('진입 직후 확인 버튼 활성 (idle)', (tester) async {
    await tester.pumpWidget(makeApp(
      NicknameMode.initialSetup,
      const AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
    ));
    final btn = tester.widget<MaterialButton>(
      find.byKey(const Key('nickname-confirm-button')),
    );
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('입력 변경 → 확인 비활성, 중복확인 활성', (tester) async {
    await tester.pumpWidget(makeApp(
      NicknameMode.initialSetup,
      const AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
    ));
    await tester.enterText(find.byType(TextField), '우주탐험가');
    await tester.pump();

    final confirm = tester.widget<MaterialButton>(
      find.byKey(const Key('nickname-confirm-button')),
    );
    expect(confirm.onPressed, isNull);

    final check = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(check.onPressed, isNotNull);
  });
}
```

> `MaterialButton` 검사는 `AppButton` 구현에 따라 다를 수 있음. 만약 `AppButton` 이 GestureDetector 기반이면 `find.byKey` + `Builder` 위젯으로 `onPressed` 가 null 인지 검사. **AppButton 구현을 먼저 확인 (`lib/core/widgets/buttons/app_button.dart`) 하고 적절한 finder 로 조정**한다. 핵심은 "버튼이 비활성 상태인지" 검증.

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/features/auth/presentation/screens/nickname_setup_screen_test.dart
```

Expected: FAIL — `NicknameSetupScreen` 클래스 본문 없음 또는 enum 만 있음

- [ ] **Step 3: NicknameSetupScreen 본 구현**

`lib/features/auth/presentation/screens/nickname_setup_screen.dart` 를 enum 정의 아래에 전체 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/nickname_form_provider.dart';
import '../widgets/nickname_input_field.dart';
import '../widgets/nickname_status_message.dart';

/// 닉네임 화면 진입 컨텍스트. 본 화면 구현은 Task 11 에서 채운다.
enum NicknameMode {
  initialSetup,
  edit,
}

class NicknameSetupScreen extends ConsumerWidget {
  const NicknameSetupScreen({super.key, required this.mode});

  final NicknameMode mode;

  bool _canSubmit(NicknameValidationStatus s) =>
      s == NicknameValidationStatus.idle ||
      s == NicknameValidationStatus.available;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial =
        ref.watch(authNotifierProvider).valueOrNull?.nickname ?? '';
    final form = ref.watch(nicknameFormNotifierProvider(initial));
    final notifier =
        ref.read(nicknameFormNotifierProvider(initial).notifier);

    return PopScope(
      canPop: mode == NicknameMode.edit,
      child: Scaffold(
        backgroundColor: AppColors.spaceBackground,
        appBar: mode == NicknameMode.edit
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  '닉네임 변경',
                  style: AppTextStyles.subHeading_18
                      .copyWith(color: Colors.white),
                ),
              )
            : null,
        body: Stack(
          children: [
            const Positioned.fill(child: SpaceBackground()),
            SafeArea(
              child: Padding(
                padding: AppPadding.all20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mode == NicknameMode.initialSetup) ...[
                      SizedBox(height: AppSpacing.s48),
                      Text(
                        '닉네임을 정해주세요',
                        style: AppTextStyles.heading_24
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(height: AppSpacing.s8),
                      Text(
                        '함께 우주를 탐험할 이름이에요',
                        style: AppTextStyles.paragraph_14
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSpacing.s32),
                    ],
                    NicknameInputField(
                      initialValue: initial,
                      currentLength: form.input.length,
                      status: form.status,
                      isCheckingDuplicate: form.isCheckingDuplicate,
                      onChanged: notifier.onInputChanged,
                      onCheckDuplicate: notifier.checkDuplicate,
                    ),
                    SizedBox(height: AppSpacing.s12),
                    NicknameStatusMessage(
                      status: form.status,
                      errorMessage: form.errorMessage,
                    ),
                    const Spacer(),
                    AppButton(
                      key: const Key('nickname-confirm-button'),
                      text: '확인',
                      isLoading: form.isSubmitting,
                      onPressed: _canSubmit(form.status) && !form.isSubmitting
                          ? () => notifier.submit(
                                mode: mode,
                                onCompleted: () {
                                  if (mode == NicknameMode.edit) {
                                    if (context.mounted) context.pop();
                                  }
                                  // initialSetup: router redirect 가 /home 으로 자동 이동
                                },
                              )
                          : null,
                      width: double.infinity,
                      height: 56.h,
                    ),
                    SizedBox(height: AppSpacing.s24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인 (Finder 조정 필요 시 수정)**

```bash
flutter test test/features/auth/presentation/screens/nickname_setup_screen_test.dart
```

만약 `find.byType(MaterialButton)` 이 AppButton 내부 구조와 안 맞으면, AppButton 의 `onPressed` 가 null 인지 검사하도록 finder 를 `find.byKey(const Key('nickname-confirm-button'))` 의 `tester.widget<AppButton>` 으로 변경:

```dart
final btn = tester.widget<AppButton>(
  find.byKey(const Key('nickname-confirm-button')),
);
expect(btn.onPressed, isNotNull);   // or isNull
```

(테스트 코드 import 에 `import 'package:space_study_ship/core/widgets/buttons/app_button.dart';` 추가)

Expected: PASS — 4 tests

- [ ] **Step 5: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/screens/nickname_setup_screen.dart \
        test/features/auth/presentation/screens/nickname_setup_screen_test.dart
git commit -m "feat : NicknameSetupScreen 본 구현 #75"
```

---

## Phase 4 — 라우터 통합

### Task 11: GoRouter redirect 분기 + GoRoute 등록 (TDD)

**Files:**
- Modify: `lib/routes/app_router.dart`
- Create: `test/routes/app_router_redirect_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/routes/app_router_redirect_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/routes/app_router.dart';
import 'package:space_study_ship/routes/route_paths.dart';

ProviderContainer makeContainer({
  required AsyncValue<AuthResultEntity?> authState,
  bool splashDone = true,
}) {
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith(() {
        final n = AuthNotifier();
        n.state = authState;
        return n;
      }),
      if (splashDone)
        splashDelayProvider.overrideWith((ref) async {
          // 즉시 has-value 상태
          return;
        }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('미로그인 → /login', () async {
    final c = makeContainer(authState: const AsyncValue.data(null));
    final router = c.read(appRouterProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go(RoutePaths.home);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.toString(),
        RoutePaths.login);
  });

  test('신규 회원 + 비-게스트 → /nickname-setup 으로 강제', () async {
    final c = makeContainer(
      authState: const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
      ),
    );
    final router = c.read(appRouterProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go(RoutePaths.home);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.toString(),
        RoutePaths.nicknameSetup);
  });

  test('isNewMember=false → /home', () async {
    final c = makeContainer(
      authState: const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: false),
      ),
    );
    final router = c.read(appRouterProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go(RoutePaths.login);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.toString(),
        RoutePaths.home);
  });

  test('게스트 + isNewMember=true (이상 케이스) → /home', () async {
    final c = makeContainer(
      authState: const AsyncValue.data(
        AuthResultEntity(
          memberId: -1,
          nickname: '게스트',
          isNewMember: true,
          isGuest: true,
        ),
      ),
    );
    final router = c.read(appRouterProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    router.go(RoutePaths.login);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(router.routerDelegate.currentConfiguration.uri.toString(),
        RoutePaths.home);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/routes/app_router_redirect_test.dart
```

Expected: FAIL — `/nickname-setup` 라우트 없음, 또는 redirect 가 `/home` 으로 보냄

- [ ] **Step 3: app_router.dart 의 redirect 교체**

`lib/routes/app_router.dart` 의 `redirect` 함수 본문을 다음으로 교체:

```dart
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final splashDone = ref.read(splashDelayProvider).hasValue;

      // 인증 로딩 중이거나 스플래시 최소 시간 미경과 → 스플래시 유지
      if (authState.isLoading ||
          (location == RoutePaths.splash && !splashDone)) {
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
        return (location == RoutePaths.nicknameSetup)
            ? null
            : RoutePaths.nicknameSetup;
      }

      // 인증 흐름 화면에 머물러 있으면 home 으로
      if (location == RoutePaths.login ||
          location == RoutePaths.splash ||
          location == RoutePaths.nicknameSetup ||
          location == RoutePaths.onboarding) {
        return RoutePaths.home;
      }

      return null;
    },
```

- [ ] **Step 4: NicknameSetupScreen import + GoRoute 등록**

`lib/routes/app_router.dart` 상단 import 추가:

```dart
import '../features/auth/presentation/screens/nickname_setup_screen.dart';
```

기존 `onboarding` GoRoute 아래(여전히 ShellRoute 외부)에 `nicknameSetup` 추가:

```dart
      GoRoute(
        path: RoutePaths.nicknameSetup,
        name: 'nicknameSetup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NicknameSetupScreen(mode: NicknameMode.initialSetup),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
```

그리고 Profile 탭의 `settings` GoRoute 안 `routes:` 리스트(현재 비어있거나 없음 — 구조 확인 후 추가)에 `nickname-edit` 추가:

```dart
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'nickname-edit',
                        name: 'nicknameEdit',
                        builder: (context, state) =>
                            const NicknameSetupScreen(mode: NicknameMode.edit),
                      ),
                    ],
                  ),
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/routes/app_router_redirect_test.dart
```

Expected: PASS — 4 tests

- [ ] **Step 6: 전체 회귀 테스트**

```bash
flutter test
```

Expected: 모든 기존 + 신규 테스트 통과. 만약 기존 router widget test 가 onboarding 자동 진입을 기대하던 게 있다면, 해당 테스트를 nickname-setup 또는 home 으로 기대값 변경 — 변경 사유를 커밋 메시지에 포함.

- [ ] **Step 7: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/routes/app_router.dart test/routes/app_router_redirect_test.dart
git commit -m "feat : isNewMember 라우팅 분기 + nickname-setup GoRoute #75"
```

---

## Phase 5 — 마무리

### Task 12: 수동 검증 + 마무리

**Files:** (코드 변경 없음, 검증만)

- [ ] **Step 1: 시뮬레이터/실기기 띄우기**

```bash
flutter run
```

- [ ] **Step 2: 시나리오 검증 체크리스트**

각 시나리오를 직접 수행하여 통과 확인:

| 시나리오 | 단계 | 기대 결과 |
|---|---|---|
| 신규 회원 첫 로그인 | 새 계정으로 Google 로그인 (서버 isNewMember=true) | /nickname-setup 진입, AppBar 없음, 시스템 백버튼 차단 |
| 신규 회원 확인 (변경 없음) | 랜덤 닉네임 그대로 "확인" 클릭 | /home 으로 이동, isNewMember=false 로 storage 저장 |
| 신규 회원 변경 후 확인 | 다른 닉네임 입력 → 중복확인 → 확인 | PATCH 호출 후 /home 이동 |
| 기존 회원 로그인 | 이미 가입된 계정 로그인 | /home 직행 (onboarding 안 거침) |
| 게스트 로그인 | "게스트로 시작하기" | /home 직행 |
| 콜드스타트 미완료 복원 | 닉네임 화면에서 앱 강제종료 → 재진입 | 닉네임 화면 자동 복귀 |
| 설정 메뉴 닉네임 변경 진입 | (별도 진입점 — 후속 spec) `/profile/settings/nickname-edit` 으로 직접 푸시 | AppBar 백버튼 보임, 변경 또는 백버튼으로 이탈 가능 |
| 잘못된 입력 형식 | "@@@" 입력 | "2~10자, 한글/영문/숫자만..." 메시지, 중복확인/확인 모두 비활성 |
| 중복 닉네임 | 이미 사용 중인 닉네임 입력 → 중복확인 | "이미 사용 중인 닉네임이에요" 메시지 |
| 네트워크 끊김 + 중복확인 | 비행기 모드 + 중복확인 클릭 | "확인에 실패했어요..." 메시지 |

- [ ] **Step 3: 정적 분석 최종 확인**

```bash
flutter analyze
```

Expected: `No issues found!`

```bash
flutter test
```

Expected: 전체 PASS

- [ ] **Step 4: 후속 작업 메모 (별도 이슈로 등록 권장)**

spec §12 의 후속 작업 항목들을 issue tracker 에 별도 이슈로 등록 (이 task 에서는 등록만, 구현 안 함):

1. 설정 메뉴에 "닉네임 변경" 진입 트리거 추가 (UI 위치/디자인 결정).
2. 기존 `updateNicknameCompleted(String)` 메서드 deprecate/정리.
3. `OnboardingScreen` 의 향후 진입점 정의(또는 제거).

- [ ] **Step 5: 최종 커밋 (변경 없으면 스킵)**

검증 단계에서 추가 수정이 없다면 커밋 없이 종료. 추가 수정이 있다면:

```bash
git add -p
git commit -m "fix : 수동 검증 보강 #75"
```

---

## Self-Review

**Spec coverage:**

- §3 redirect 분기 → Task 11 ✓
- §4.2 RoutePaths 추가 → Task 1 ✓ / GoRoute 등록 → Task 11 ✓
- §4.3 NicknameFormState/Status → Task 4 ✓
- §4.4 NicknameFormNotifier (build/onInputChanged/checkDuplicate/submit) → Task 5, 6, 7 ✓
- §4.5 markNicknameConfirmed + updateNickname storage 동기화 → Task 2, 3 ✓
- §4.6 NicknameSetupScreen 본 구현 (PopScope, mode 분기, onCompleted) → Task 10 ✓
- §4.7 NicknameInputField (Row + AppTextField + OutlinedButton + 외부 카운터, suffixIcon 사용 안 함) → Task 8 ✓
- §5 상태 전이표 → Task 5 의 onInputChanged 케이스, Task 6 의 checkDuplicate 케이스, Task 7 의 submit 케이스 ✓
- §6 에러 처리 → Task 6, 7 (각 예외 매핑) + 위젯 메시지 표시 → Task 9 ✓
- §7 콜드스타트 복원 → 코드 추가 불필요 (기존 AuthNotifier.build 가 storage 복원). Task 11 의 redirect 분기가 자연스럽게 처리. 명시적 자동화 테스트는 단위로는 어렵고 수동 검증 Task 12 에서 다룸 ✓
- §8 테스트 전략 → Task 2/3/5/6/7/10/11 단위·위젯·라우터 테스트 ✓ / 수동 검증 → Task 12 ✓

**Placeholder scan:**
- "TBD"/"TODO" 흔적 0.
- 각 Step 에 실제 코드 또는 명령어 포함.
- "Similar to Task N" 흔적 없음 (Task 간 코드 중복은 명시적으로 반복).

**Type consistency:**
- `NicknameValidationStatus` 의 5개 값 — 모든 Task 에서 동일 (idle/invalidFormat/needsCheck/available/unavailable).
- `NicknameMode` 의 2개 값 — Task 7, 10, 11 에서 동일.
- `NicknameFormNotifier.submit({mode, onCompleted})` 시그니처 — Task 7 정의, Task 10 호출부 일치.
- `AuthNotifier.markNicknameConfirmed() : Future<void>` — Task 2 정의, Task 7 호출부 일치.

리뷰 통과. plan 저장 완료.

---

**Plan complete and saved to `docs/superpowers/plans/2026-05-20-first-login-nickname-branching-plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - 각 Task 마다 신선한 subagent 디스패치, Task 간 리뷰, 빠른 반복

**2. Inline Execution** - 이 세션에서 직접 진행, 중간 checkpoint 에서 리뷰

**Which approach?**
