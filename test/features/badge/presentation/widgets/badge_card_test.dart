import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/constants/space_icons.dart';
import 'package:space_study_ship/features/badge/domain/entities/badge_entity.dart';
import 'package:space_study_ship/features/badge/presentation/widgets/badge_card.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => child,
      ),
    ),
  );
}

void main() {
  group('BadgeCard', () {
    testWidgets('잠금 상태에서 lock 아이콘 렌더링', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const BadgeCard(
            icon: SpaceIcons.rocket,
            name: 'Test Badge',
            isUnlocked: false,
            rarity: BadgeRarity.normal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('\u{1F512}'), findsNothing);
    });

    testWidgets('해금 상태에서 실제 뱃지 아이콘 렌더링', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const BadgeCard(
            icon: SpaceIcons.rocket,
            name: 'Test Badge',
            isUnlocked: true,
            rarity: BadgeRarity.normal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });
}
