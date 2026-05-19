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
        builder: (_, _) => MaterialApp(
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
        AppDialog(title: '제목', confirmText: '확인', onConfirm: () {}),
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
