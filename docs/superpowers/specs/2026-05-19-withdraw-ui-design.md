# 회원 탈퇴 UI 추가 (#71 후속)

> 백엔드 호출은 이미 #71 본체에서 완성됨 (`AuthNotifier.withdraw()` + 라우터 자동 redirect). 이번 작업은 사용자가 그 기능에 접근할 수 있는 UI 만 추가한다.

| 항목 | 값 |
|---|---|
| 이슈 | #71 후속 — UI 마무리 |
| 작업 브랜치 | `20260423_#71_백엔드_Auth_API_연동_소셜_로그인_토큰_닉네임_탈퇴` (계속 사용) |
| 의존 spec | `docs/superpowers/specs/2026-05-15-auth-api-alignment-design.md` |
| Out-of-scope | 닉네임 설정/변경 화면, GoRouter `isNewMember` destination 연결 |

---

## 1. 배경

#71 본체에서 6 Auth 엔드포인트를 정렬하고 `AuthNotifier.withdraw()` 메서드까지 구현 완료. `app_router.dart:86-87` 가 `authNotifier.state.value == null` 시 로그인 화면으로 자동 리다이렉트하므로 라우팅 작업 불필요. 그러나 사용자가 `withdraw()` 를 트리거할 UI 가 어디에도 없어 dead feature 상태. 본 spec 이 그 UI 를 추가한다.

또한 일반 destructive 액션 (탈퇴 / 데이터 영구 삭제 등) 에 적합한 confirmation textfield 패턴 (GitHub, Vercel 등이 사용) 을 `AppDialog` 에 일반화하여 향후 재사용 가능하게 한다.

---

## 2. 현황

| 항목 | 상태 |
|---|---|
| `AuthRepository.withdraw()` | ✅ 구현됨 (#71 Task 11) |
| `WithdrawUseCase` | ✅ 구현됨 (#71 Task 12) |
| `AuthNotifier.withdraw()` | ✅ 구현됨 — `state = AsyncValue.data(null)` 로 종료 (#71 Task 13) |
| GoRouter 의 null state 처리 | ✅ `app_router.dart:86-87` 이미 로그인 화면으로 리다이렉트 |
| ProfileScreen 의 탈퇴 메뉴 | ❌ 없음 — 로그아웃 메뉴만 (`profile_screen.dart:213-231`) |
| AppDialog 의 confirmation phrase 입력 옵션 | ❌ 없음 — `customContent` slot 만 존재 |

---

## 3. 결정 사항 (확정)

| ID | 결정 | 근거 |
|---|---|---|
| D-1 | Confirmation phrase = `["탈퇴하기", "delete"]`, case-insensitive + trim 매칭 | 한국어 사용자 / 영문 입력 모드 사용자 모두 빠른 입력 가능. 사용자 선택 |
| D-2 | `AppDialog` 에 옵션 추가 (별도 위젯 X) | 일반 destructive 패턴으로 재사용 가능. 사용자 명시 요청 |
| D-3 | 게스트는 메뉴 자체 숨김 | 게스트는 회원이 아니므로 탈퇴 대상 아님. 기존 `isGuestProvider` 활용 |
| D-4 | API 실패 시 다이얼로그 닫고 `AppSnackBar.error` | 기존 로그아웃 패턴과 동일 |
| D-5 | 진행 중 (await) UX = 확인 버튼 isLoading + 취소 버튼 disable + textfield readOnly | 사용자 재입력 차단, 중복 호출 방지 |
| D-6 | `AppDialog.confirm()` (기존 bool 반환) 시그니처 변경 없음 | Backward compatible — phrase 옵션 추가하더라도 기존 호출자 영향 없음 |
| D-7 | 진행 중 외부 탭 dismiss 차단은 별도 처리 안 함 | `barrierDismissible: true` 유지. 사용자가 외부 탭 시 취소 의도 — 자연스러운 UX |

---

## 4. 아키텍처

### 4.1 의존성 흐름 (변화 없음)

```
ProfileScreen (탭 핸들러)
    ↓
AppDialog.show(confirmationPhrases: [...], onConfirm: ...)
    ↓ (사용자 phrase 입력 + 확인)
AuthNotifier.withdraw()    [#71 본체 완성됨]
    ↓
WithdrawUseCase → AuthRepository → AuthRemoteDataSource (DELETE)
    ↓
state = AsyncValue.data(null)
    ↓
app_router.dart redirect → /login
```

### 4.2 AppDialog 의 새 동작 분기

```
build():
  if confirmationPhrases != null:
    StatefulWidget 으로 controller 보유
    textfield 표시 (hint = confirmationHint)
    매칭 = input.trim().toLowerCase() ∈ phrases.map(toLowerCase)
    onConfirm 버튼 onPressed = 매칭이면 본래 콜백, 아니면 null
    텍스트 변경 시 setState() 로 리빌드 (실시간 활성/비활성)
  else:
    기존 동작 (StatelessWidget 과 동등)
```

기존 caller (`AppDialog.confirm`, phrase 옵션 안 쓴 `AppDialog.show`) 는 `confirmationPhrases == null` 이라 분기되지 않고 동일하게 동작.

---

## 5. 변경 파일 매트릭스

### 5.1 수정 파일

| 파일 | 변경 요약 |
|---|---|
| `lib/core/widgets/dialogs/app_dialog.dart` | StatelessWidget → StatefulWidget 전환. (a) 신규 파라미터 `List<String>? confirmationPhrases`, `String? confirmationHint`, (b) `show()` 정적 메서드에도 두 파라미터 추가, (c) `confirm()` 은 시그니처 변경 없음, (d) phrase 있으면 build() 에 textfield 렌더링 + 실시간 매칭 검증, (e) 확인 버튼 `onPressed` 가 매칭 시에만 callback 활성화 |
| `lib/features/profile/presentation/screens/profile_screen.dart` | `_buildMenuList` 의 로그아웃 메뉴 다음에 `if (!isGuest)` 가드한 "회원 탈퇴" 메뉴 추가. 탭 핸들러: `AppDialog.show(confirmationPhrases: ['탈퇴하기', 'delete'], confirmationHint: '...', onConfirm: () async { try { await ref.read(authNotifierProvider.notifier).withdraw(); } catch (e) { if (context.mounted) AppSnackBar.error(context, '탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.'); } })` |

### 5.2 신규 파일

| 파일 | 내용 |
|---|---|
| `test/core/widgets/dialogs/app_dialog_test.dart` | AppDialog 위젯 테스트 — phrase 없을 때 textfield 없음, phrase 있을 때 표시, exact match 시 확인 enable, case-insensitive 매칭, trim, 미매칭 입력 시 확인 disable |

(`profile_screen_test.dart` 신규 생성은 선택 — 기존 패턴상 ProfileScreen 단위 테스트가 없으니 본 spec 에서도 추가하지 않음. ProfileScreen 의 탈퇴 메뉴 표시는 수동 검증)

---

## 6. AppDialog 변경 상세

### 6.1 새 시그니처

```dart
class AppDialog extends StatefulWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.customContent,
    this.confirmationPhrases,   // NEW
    this.confirmationHint,      // NEW
  });

  // ... 기존 final 필드 ...

  /// 확인 텍스트필드 phrase 후보. 입력값이 trim+lowercase 매칭되어야 확인 버튼 활성화.
  /// null 이면 textfield 표시 안 함 (기존 동작).
  final List<String>? confirmationPhrases;

  /// 확인 텍스트필드 hint. confirmationPhrases 가 있을 때만 사용.
  final String? confirmationHint;

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  bool get _isConfirmEnabled {
    if (widget.confirmationPhrases == null) return true;
    final normalized = _controller.text.trim().toLowerCase();
    return widget.confirmationPhrases!
        .any((p) => p.toLowerCase() == normalized);
  }

  // build() 에서 confirmationPhrases != null 이면 message 다음에 textfield 렌더링
  // 확인 버튼은 onPressed: _isConfirmEnabled ? widget.onConfirm : null
}
```

### 6.2 `show()` / `confirm()` 변경

- `show()` — `confirmationPhrases`, `confirmationHint` 파라미터 추가 (기본 null). pageBuilder 안의 `AppDialog(...)` 생성자에 전달
- `confirm()` — **변경 없음** (이 단축 메서드는 단순 확인용으로 유지)

### 6.3 Textfield 위젯 선택

프로젝트 전역 widget 카탈로그에 `SpaceTextField` 가 있지만, dialog 안에서 사용할 가벼운 인풋이므로 기본 `TextField` 를 사용 (Material 기본 + AppColors 적용). 새 외부 의존 추가 없음.

---

## 7. ProfileScreen 변경 상세

### 7.1 탈퇴 메뉴 추가

`_buildMenuList(context, ref)` 안의 로그아웃 메뉴 `_buildMenuItem(...)` 호출 다음에 추가:

```dart
if (!isGuest) ...[
  _buildMenuItem(
    icon: Icons.delete_forever_outlined,
    title: '회원 탈퇴',
    iconColor: AppColors.error,
    textColor: AppColors.error,
    showChevron: false,
    onTap: () => _onWithdrawTap(context, ref),
  ),
],
```

### 7.2 탈퇴 핸들러

`ProfileScreen` 의 private 메서드로 추출 (build 메서드 비대화 방지):

```dart
Future<void> _onWithdrawTap(BuildContext context, WidgetRef ref) async {
  await AppDialog.show<void>(
    context: context,
    title: '정말 탈퇴하시겠어요?',
    message: '계정과 모든 학습 기록이 영구 삭제돼요. 되돌릴 수 없어요.\n\n'
             '확인을 위해 "탈퇴하기" 또는 "delete" 를 입력해 주세요.',
    confirmationPhrases: const ['탈퇴하기', 'delete'],
    confirmationHint: '탈퇴하기 또는 delete 입력',
    confirmText: '탈퇴',
    cancelText: '취소',
    isDestructive: true,
    onConfirm: () async {
      try {
        await ref.read(authNotifierProvider.notifier).withdraw();
        // 성공 시 라우터가 자동 로그인 화면 이동
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.error(context, '탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.');
        }
      }
    },
  );
}
```

### 7.3 import 추가

ProfileScreen 에 다음 import 추가 (현재 미존재):
```dart
import '../../../../core/widgets/feedback/app_snackbar.dart';
```

---

## 8. Test 전략

### 8.1 `app_dialog_test.dart` (신규)

| Case | 검증 |
|---|---|
| phrase 없을 때 textfield 미표시 | `find.byType(TextField)` 가 0 |
| phrase 있을 때 textfield 표시 + 확인 버튼 disable | TextField 존재 + 확인 버튼 `onPressed == null` |
| phrase 정확 입력 시 확인 버튼 enable | 입력 후 pump → 확인 버튼 `onPressed != null` |
| case-insensitive 매칭 | `'DELETE'`, `'Delete'`, `'delete'` 모두 enable |
| trim 매칭 | `'  탈퇴하기  '` 도 enable |
| phrase 중 두 번째 항목 매칭 (`'delete'`) | enable |
| 미매칭 입력 (`'xyz'`) | 확인 버튼 disable 유지 |

(7 케이스 이상)

### 8.2 ProfileScreen 수동 검증

- 게스트 로그인 → 프로필 → 탈퇴 메뉴 안 보임
- 일반 회원 로그인 → 프로필 → 로그아웃 아래 탈퇴 메뉴 표시
- 탈퇴 메뉴 탭 → 다이얼로그 표시, 확인 버튼 disable
- "탈퇴" / "탈퇴하기까지 입력" → disable 유지 → "탈퇴하기" 완료 입력 → enable
- 확인 → 백엔드 204 → 로그인 화면 자동 이동
- 백엔드 5xx 모킹 시 → 다이얼로그 닫히고 에러 스낵바

---

## 9. Risks & Mitigation

| Risk | 대응 |
|---|---|
| StatelessWidget → StatefulWidget 전환이 기존 caller 깸 | 모든 기존 호출자가 `final` 파라미터만 사용 → 동작 동일. `confirm()` 시그니처 무변경 |
| Dialog dismiss 타이밍 race | `onConfirm` 콜백 본문에서 `Navigator.pop` 먼저 (기존 패턴), 이후 `await withdraw()`. 스낵바는 다이얼로그 닫힌 후 표시. `context.mounted` 가드로 누수 방지 |
| 한글 IME composing 중 매칭 깜빡임 | 의도된 동작 — composing 중에는 미매칭 → disable, 완성 후 매칭 → enable. 별도 처리 불필요 |
| 사용자가 phrase 외운 후 즉시 입력 → 의도치 않은 탈퇴 | confirmation phrase 자체가 mitigation. 추가 확인은 over-engineering |
| AppButton 이 `onPressed: null` 일 때 disable 시각 표현 부재 | AppButton 의 기존 disabled 스타일을 확인하여 시각적 구분 — 미흡 시 본 spec 의 plan 에서 보강 결정 |

---

## 10. 성공 기준

1. `flutter analyze` 0 issue
2. `app_dialog_test.dart` 7+ tests 통과
3. AppDialog 기존 caller 모두 회귀 없음 (`flutter test` 전체 그린)
4. ProfileScreen 에 탈퇴 메뉴 표시 (게스트는 숨김)
5. 탈퇴 흐름 end-to-end 수동 검증 통과 (백엔드 모킹 또는 실제 호출)
6. AppDialog 의 `confirm()` 정적 메서드 시그니처 변경 없음

---

## 11. 후속 작업 (별도 spec)

- 닉네임 설정 화면 (NicknameSetupScreen) — 신규 가입 시 isNewMember 분기 destination
- 닉네임 변경 화면 (NicknameEditScreen) — 프로필 메뉴에 "닉네임 변경" 항목 + UseCase 연동
- GoRouter 의 `isNewMember` 분기 → NicknameSetupScreen 연결
