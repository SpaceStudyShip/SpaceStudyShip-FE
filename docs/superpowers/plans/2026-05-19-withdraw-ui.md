# Withdraw UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 사용자가 회원 탈퇴를 실행할 UI 를 추가한다 — AppDialog 에 confirmation textfield 옵션 + ProfileScreen 의 메뉴 항목 (로그아웃 아래, 게스트 숨김).

**Architecture:** `AppDialog` 를 StatelessWidget → StatefulWidget 으로 전환하면서 `confirmationPhrases` / `confirmationHint` 두 옵션 추가. phrase 가 주어지면 TextField 를 렌더링하고, 입력값을 `trim+lowercase` 후 phrase 후보와 비교하여 매칭될 때만 확인 버튼 enable. `ProfileScreen._buildMenuList` 의 로그아웃 메뉴 다음에 `if (!isGuest)` 가드한 "회원 탈퇴" 메뉴 추가. 탭 시 `AppDialog.show(confirmationPhrases: ['탈퇴하기', 'delete'], …, onConfirm: …)` 호출 → `AuthNotifier.withdraw()` 트리거 (이미 #71 본체에서 완성) → 라우터가 state=null 감지 후 로그인 화면 자동 이동. 실패 시 다이얼로그 닫고 `AppSnackBar.error`.

**Tech Stack:** Flutter 3.9 · flutter_test · Riverpod 2.6 (`AppDialog` widget 테스트는 mocktail 없이 순수 위젯 테스트)

**Spec:** `docs/superpowers/specs/2026-05-19-withdraw-ui-design.md`

---

## File Structure (변경 요약)

### Created
- `test/core/widgets/dialogs/app_dialog_test.dart` (9 widget tests)

### Modified
- `lib/core/widgets/dialogs/app_dialog.dart` (Stateless → Stateful, 2 신규 옵션)
- `lib/features/profile/presentation/screens/profile_screen.dart` (메뉴 항목 + 핸들러 + import)

### Unchanged
- `AuthNotifier.withdraw()` / `WithdrawUseCase` / `AuthRepository.withdraw` — #71 본체에서 완성
- `app_router.dart` — `state.value == null` 시 로그인 화면 redirect 이미 구현됨

---

## Pre-flight Check

- [ ] **브랜치 확인**

```bash
git branch --show-current
```

Expected: `20260423_#71_백엔드_Auth_API_연동_소셜_로그인_토큰_닉네임_탈퇴`

- [ ] **워킹 트리 clean 확인**

```bash
git status --short
```

Expected: 출력 비어있음.

- [ ] **테스트 베이스라인 그린**

```bash
flutter analyze
flutter test
```

Expected: analyze 0 issue, 모든 테스트 통과.

---

### Task 1: AppDialog 에 confirmation phrase 옵션 추가

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart` (전체 재작성)
- Create: `test/core/widgets/dialogs/app_dialog_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/core/widgets/dialogs/app_dialog_test.dart` 신규 생성:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/widgets/buttons/app_button.dart';
import 'package:space_study_ship/core/widgets/dialogs/app_dialog.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          home: Scaffold(body: Center(child: dialog)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppButton confirmButton(WidgetTester tester, String confirmText) {
    return tester.widget<AppButton>(
      find.widgetWithText(AppButton, confirmText),
    );
  }

  group('AppDialog without confirmationPhrases (기존 동작 보존)', () {
    testWidgets('TextField 미표시', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          message: '메시지',
          confirmText: '탈퇴',
          cancelText: '취소',
          onConfirm: () {},
        ),
      );

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('확인 버튼이 항상 enable (onPressed != null)', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '확인',
          onConfirm: () {},
        ),
      );

      expect(confirmButton(tester, '확인').onPressed, isNotNull);
    });
  });

  group('AppDialog with confirmationPhrases', () {
    testWidgets('TextField 표시 + 초기 확인 버튼 disable', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '정말 탈퇴하시겠어요?',
          message: '메시지',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          confirmationHint: '탈퇴하기 또는 delete 입력',
          onConfirm: () {},
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(confirmButton(tester, '탈퇴').onPressed, isNull);
    });

    testWidgets('첫 번째 phrase 정확 입력 시 확인 버튼 enable', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), '탈퇴하기');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNotNull);
    });

    testWidgets('두 번째 phrase 정확 입력 시 확인 버튼 enable', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNotNull);
    });

    testWidgets('case-insensitive 매칭 (DELETE)', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNotNull);
    });

    testWidgets('trim 매칭 (앞뒤 공백 포함)', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), '  탈퇴하기  ');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNotNull);
    });

    testWidgets('미매칭 입력 → 확인 버튼 disable 유지', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNull);
    });

    testWidgets('일부만 입력 (탈퇴) → disable 유지', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), '탈퇴');
      await tester.pump();

      expect(confirmButton(tester, '탈퇴').onPressed, isNull);
    });

    testWidgets('매칭 후 다시 미매칭 입력 → 다시 disable', (tester) async {
      await pumpDialog(
        tester,
        AppDialog(
          title: '제목',
          confirmText: '탈퇴',
          cancelText: '취소',
          confirmationPhrases: const ['탈퇴하기', 'delete'],
          onConfirm: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), '탈퇴하기');
      await tester.pump();
      expect(confirmButton(tester, '탈퇴').onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'partial');
      await tester.pump();
      expect(confirmButton(tester, '탈퇴').onPressed, isNull);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/core/widgets/dialogs/app_dialog_test.dart
```

Expected: 컴파일 에러 (`confirmationPhrases` named param 없음) 또는 모든 with-phrase 테스트 FAIL.

- [ ] **Step 3: `lib/core/widgets/dialogs/app_dialog.dart` 를 다음으로 전체 교체**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';
import '../buttons/app_button.dart';

/// 앱 전역에서 사용하는 다이얼로그 컴포넌트 - 토스 스타일
///
/// **기본 스펙**:
/// - 모서리: 24px 라운드
/// - 배경: spaceElevated
/// - 애니메이션: 스케일 + 페이드
///
/// **사용 예시**:
/// ```dart
/// // 기본 다이얼로그
/// AppDialog.show(
///   context: context,
///   title: '저장할까요?',
///   message: '변경사항이 저장돼요',
///   onConfirm: () => save(),
/// );
///
/// // 확인/취소 다이얼로그
/// AppDialog.show(
///   context: context,
///   title: '삭제할까요?',
///   message: '삭제하면 되돌릴 수 없어요',
///   confirmText: '삭제',
///   cancelText: '취소',
///   isDestructive: true,
///   onConfirm: () => delete(),
/// );
///
/// // Confirmation phrase 입력 (탈퇴 등 destructive action)
/// AppDialog.show(
///   context: context,
///   title: '정말 탈퇴하시겠어요?',
///   message: '되돌릴 수 없어요. 확인을 위해 phrase 를 입력해 주세요.',
///   confirmationPhrases: ['탈퇴하기', 'delete'],
///   confirmationHint: '탈퇴하기 또는 delete 입력',
///   confirmText: '탈퇴',
///   cancelText: '취소',
///   isDestructive: true,
///   onConfirm: () => withdraw(),
/// );
///
/// // 간편 확인 (bool 반환)
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '저장할까요?',
/// );
/// if (result == true) { /* 저장 */ }
/// ```
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
    this.confirmationPhrases,
    this.confirmationHint,
  });

  /// 제목 (필수)
  final String title;

  /// 메시지 (선택)
  final String? message;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 없음)
  final String? cancelText;

  /// 확인 콜백
  final VoidCallback? onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 위험 액션 여부 (true면 확인 버튼 빨간색)
  final bool isDestructive;

  /// 커스텀 콘텐츠 (message 대신 사용)
  final Widget? customContent;

  /// 확인 텍스트필드 phrase 후보 (예: `['탈퇴하기', 'delete']`).
  ///
  /// 입력값이 `trim().toLowerCase()` 변환 후 후보 중 하나와 매치되어야
  /// 확인 버튼이 활성화됨. null 이면 textfield 표시 안 함 (기존 동작 유지).
  final List<String>? confirmationPhrases;

  /// 확인 텍스트필드 hint. [confirmationPhrases] 가 있을 때만 사용.
  final String? confirmationHint;

  // ============================================
  // 정적 메서드
  // ============================================

  /// 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? customContent,
    List<String>? confirmationPhrases,
    String? confirmationHint,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: TossDesignTokens.animationNormal,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          customContent: customContent,
          confirmationPhrases: confirmationPhrases,
          confirmationHint: confirmationHint,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onConfirm?.call();
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            onCancel?.call();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: TossDesignTokens.springCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// 간편 확인 다이얼로그 (bool 반환)
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) async {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: TossDesignTokens.animationNormal,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: TossDesignTokens.springCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  late final TextEditingController _confirmationController;

  @override
  void initState() {
    super.initState();
    _confirmationController = TextEditingController()
      ..addListener(_onConfirmationChanged);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _onConfirmationChanged() {
    // Trigger rebuild so confirm button reflects match state.
    setState(() {});
  }

  /// 확인 버튼 활성 여부.
  ///
  /// `confirmationPhrases` 가 null 이면 항상 true (기존 동작).
  /// 있으면 입력값 `trim().toLowerCase()` 가 후보 중 하나와 일치해야 true.
  bool get _isConfirmEnabled {
    final phrases = widget.confirmationPhrases;
    if (phrases == null) return true;
    final normalized = _confirmationController.text.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return phrases.any((p) => p.toLowerCase() == normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.w,
        margin: AppPadding.horizontal24,
        padding: AppPadding.all24,
        decoration: BoxDecoration(
          color: AppColors.spaceElevated,
          borderRadius: AppRadius.xxlarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Text(
                widget.title,
                style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),

              // 메시지 또는 커스텀 콘텐츠
              if (widget.message != null || widget.customContent != null) ...[
                SizedBox(height: AppSpacing.s24),
                widget.customContent ??
                    Text(
                      widget.message!,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ],

              // Confirmation textfield (phrase 가 주어진 경우)
              if (widget.confirmationPhrases != null) ...[
                SizedBox(height: AppSpacing.s16),
                TextField(
                  controller: _confirmationController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label_16.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: widget.confirmationHint,
                    hintStyle: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.spaceSurface,
                    contentPadding: AppPadding.all12,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.medium,
                      borderSide: BorderSide(color: AppColors.spaceDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.medium,
                      borderSide: BorderSide(
                        color: widget.isDestructive
                            ? AppColors.error
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.s24),

              // 버튼들
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final hasCancel = widget.cancelText != null;
    final confirmCallback = _isConfirmEnabled ? widget.onConfirm : null;

    if (hasCancel) {
      return Row(
        children: [
          // 취소 버튼
          Expanded(
            child: AppButton(
              text: widget.cancelText!,
              backgroundColor: AppColors.spaceSurface,
              borderColor: AppColors.spaceDivider,
              foregroundColor: AppColors.textSecondary,
              height: 48.h,
              onPressed: widget.onCancel,
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          // 확인 버튼
          Expanded(
            child: AppButton(
              text: widget.confirmText,
              backgroundColor: widget.isDestructive
                  ? AppColors.error
                  : AppColors.primary,
              borderColor: widget.isDestructive
                  ? AppColors.error
                  : AppColors.primaryDark,
              height: 48.h,
              onPressed: confirmCallback,
            ),
          ),
        ],
      );
    }

    // 확인 버튼만
    return AppButton(
      text: widget.confirmText,
      backgroundColor: widget.isDestructive
          ? AppColors.error
          : AppColors.primary,
      borderColor: widget.isDestructive
          ? AppColors.error
          : AppColors.primaryDark,
      width: double.infinity,
      height: 48.h,
      onPressed: confirmCallback,
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/core/widgets/dialogs/app_dialog_test.dart
```

Expected: 9 tests passed.

- [ ] **Step 5: 기존 caller 회귀 점검**

```bash
flutter analyze
flutter test
```

Expected: analyze 0 issue. 모든 테스트 그린. AppDialog 의 기존 호출자 (예: `profile_screen.dart` 의 로그아웃 다이얼로그, 다른 화면에서 `AppDialog.show` / `AppDialog.confirm` 사용처) 영향 없음 — 새 옵션 추가는 backward compatible.

- [ ] **Step 6: 커밋**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart test/core/widgets/dialogs/app_dialog_test.dart
git commit -m "feat : AppDialog 에 confirmation phrase 옵션 추가 #71"
```

---

### Task 2: ProfileScreen 에 회원 탈퇴 메뉴 추가

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

- [ ] **Step 1: import 블록에 AppSnackBar 추가**

`lib/features/profile/presentation/screens/profile_screen.dart` 의 기존 import 블록에 추가 (알파벳/경로 순서 — `app_dialog.dart` import 옆에 배치):

```dart
import '../../../../core/widgets/feedback/app_snackbar.dart';
```

- [ ] **Step 2: `_buildMenuList` 의 로그아웃 메뉴 다음에 탈퇴 메뉴 추가**

기존 코드에서 `_buildMenuList` 의 마지막 `_buildMenuItem(...로그아웃...)` 호출의 닫는 `)`, 다음 줄에 추가. `Column.children` 리스트의 마지막 요소가 되도록.

기존 (`profile_screen.dart:213-231` 근방):
```dart
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: '로그아웃',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          showChevron: false,
          onTap: () async {
            final confirmed = await AppDialog.confirm(
              context: context,
              title: '로그아웃하시겠어요?',
              message: isGuest ? '게스트 모드의 데이터가\n모두 초기화돼요' : null,
              isDestructive: isGuest,
              confirmText: '로그아웃',
              cancelText: '취소',
            );
            if (confirmed == true) {
              await ref.read(authNotifierProvider.notifier).signOut();
            }
          },
        ),
      ],
    );
  }
```

다음으로 교체 (로그아웃 메뉴 항목 뒤에 `if (!isGuest)` spread 추가):

```dart
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: '로그아웃',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          showChevron: false,
          onTap: () async {
            final confirmed = await AppDialog.confirm(
              context: context,
              title: '로그아웃하시겠어요?',
              message: isGuest ? '게스트 모드의 데이터가\n모두 초기화돼요' : null,
              isDestructive: isGuest,
              confirmText: '로그아웃',
              cancelText: '취소',
            );
            if (confirmed == true) {
              await ref.read(authNotifierProvider.notifier).signOut();
            }
          },
        ),
        if (!isGuest)
          _buildMenuItem(
            icon: Icons.delete_forever_outlined,
            title: '회원 탈퇴',
            iconColor: AppColors.error,
            textColor: AppColors.error,
            showChevron: false,
            onTap: () => _onWithdrawTap(context, ref),
          ),
      ],
    );
  }
```

- [ ] **Step 3: `_onWithdrawTap` private 메서드 추가**

`ProfileScreen` 클래스 안, `_buildMenuItem` 메서드 정의 다음 (클래스 닫는 `}` 직전) 에 추가:

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
          // 성공 시 라우터가 state=null 감지 후 로그인 화면 자동 이동.
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.error(
              context,
              '탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.',
            );
          }
        }
      },
    );
  }
```

- [ ] **Step 4: analyze 통과 확인**

```bash
flutter analyze
```

Expected: 0 issue.

- [ ] **Step 5: 전체 테스트 그린 확인**

```bash
flutter test
```

Expected: 모든 테스트 통과 (AppDialog test 포함).

- [ ] **Step 6: 커밋**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat : 프로필에 회원 탈퇴 메뉴 추가 (로그아웃 아래, 게스트 숨김) #71"
```

---

### Task 3: 통합 검증

**Files:** (검증만, 코드 변경 없음)

- [ ] **Step 1: build_runner 재실행 (일관성)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: 성공. 만약 변경된 .freezed.dart / .g.dart 가 있으면 별도 chore commit 으로 분리.

- [ ] **Step 2: 만약 변경된 파일 있으면 chore commit**

```bash
git status --short
```

만약 변경 표시되면:
```bash
git add lib/
git commit -m "chore : build_runner 재실행으로 생성 파일 일관성 확보 #71"
```

(없으면 skip)

- [ ] **Step 3: flutter analyze 전체**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: flutter test 전체**

```bash
flutter test
```

Expected: 모든 테스트 (Task 1 의 9개 신규 + 기존 모두) 통과.

- [ ] **Step 5: 성공 기준 매뉴얼 체크 (spec Section 10)**

```bash
# 1. AppDialog 의 신규 옵션 존재
grep -n "confirmationPhrases\|confirmationHint" lib/core/widgets/dialogs/app_dialog.dart | head -5
# Expected: 클래스 필드, 생성자 파라미터, show() 파라미터, build() 분기 등 다수 hits

# 2. AppDialog 가 StatefulWidget
grep -n "class AppDialog extends" lib/core/widgets/dialogs/app_dialog.dart
# Expected: extends StatefulWidget

# 3. confirm() 정적 메서드 시그니처 변경 없음 (backward compat)
grep -A5 "static Future<bool?> confirm" lib/core/widgets/dialogs/app_dialog.dart | head -8
# Expected: required BuildContext, required String title, message, confirmText, cancelText, isDestructive — 6 param 만

# 4. ProfileScreen 에 탈퇴 메뉴
grep -n "회원 탈퇴\|_onWithdrawTap" lib/features/profile/presentation/screens/profile_screen.dart
# Expected: 2+ hits (메뉴 title + 핸들러 정의 + 호출)

# 5. 게스트 가드
grep -B2 -A4 "회원 탈퇴" lib/features/profile/presentation/screens/profile_screen.dart | head -10
# Expected: `if (!isGuest)` 가드 안에 위치

# 6. AppSnackBar import
grep "app_snackbar.dart" lib/features/profile/presentation/screens/profile_screen.dart
# Expected: 1 hit
```

- [ ] **Step 6: 수동 UX 검증 (가능한 경우)**

가능하면 시뮬레이터/디바이스에서:
- 일반 회원 로그인 → 프로필 → 로그아웃 아래 "회원 탈퇴" 메뉴 표시 확인
- 메뉴 탭 → 다이얼로그 표시, 확인 버튼 disable
- "탈퇴" 입력 → disable 유지
- "탈퇴하기" 완료 입력 → enable 전환
- "탈퇴" 버튼 탭 → 백엔드 호출 → 성공 시 로그인 화면 이동
- 게스트 로그인 → 프로필 → 탈퇴 메뉴 안 보임

자동화 테스트가 cover 하지 못하는 흐름은 매뉴얼 검증으로 보완. 환경 불가 시 skip 하고 PR description 에 명시.

- [ ] **Step 7: git log 정렬 확인**

```bash
git log --oneline origin/main..HEAD
```

Expected: 본 plan 의 task 별 커밋 + #71 본체 커밋이 모두 origin/main 위에 정렬됨.

---

## Rollback Plan

만약 머지 후 UX 문제 발견 시:

```bash
git revert <merge-commit-sha>
```

각 task 가 독립 커밋이므로 부분 revert 도 가능 (예: ProfileScreen 메뉴만 revert하고 AppDialog 옵션은 유지). 다만 부분 revert 는 일반적으로 권장하지 않음.

---

## Notes / Followups (Out of Scope)

- 닉네임 설정 화면 (NicknameSetupScreen) — 신규 가입 isNewMember destination
- 닉네임 변경 화면 (NicknameEditScreen) — 프로필 메뉴 + UseCase 연동
- GoRouter 의 `isNewMember` 분기 destination 연결
- AppDialog 의 다른 confirmation phrase 활용처 (데이터 영구 삭제 등) — 본 spec 에서는 도구만 제공
