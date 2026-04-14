import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:space_study_ship/features/settings/data/providers/settings_data_providers.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/screens/friend_detail_screen.dart';
import 'package:space_study_ship/features/social/presentation/widgets/live_session_ring.dart';

const _studying = FriendEntity(
  id: 'u1',
  name: '김우주',
  status: FriendStatus.studying,
  studyDuration: Duration(hours: 2, minutes: 14),
  currentSubject: '수학',
  weeklyStudyDuration: Duration(hours: 16, minutes: 20),
);

const _offline = FriendEntity(
  id: 'u6',
  name: '한은하',
  status: FriendStatus.offline,
  weeklyStudyDuration: Duration(hours: 2, minutes: 15),
);

late SettingsLocalDataSource _settingsDataSource;

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        settingsLocalDataSourceProvider.overrideWithValue(_settingsDataSource),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp(home: child),
      ),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    _settingsDataSource = SettingsLocalDataSource(prefs);
  });

  Future<void> pumpScreen(WidgetTester tester, FriendEntity friend) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(FriendDetailScreen(friend: friend)));
    await tester.pump();
  }

  group('FriendDetailScreen (D2)', () {
    testWidgets('친구 이름이 표시된다', (tester) async {
      await pumpScreen(tester, _studying);
      expect(find.text('김우주'), findsOneWidget);
    });

    testWidgets('공부 중 친구는 헤더에 현재 과목이 함께 표시된다', (tester) async {
      await pumpScreen(tester, _studying);
      expect(find.text('지금 공부 중 · 수학'), findsOneWidget);
    });

    testWidgets('LiveSessionRing 위젯이 표시된다', (tester) async {
      await pumpScreen(tester, _studying);
      expect(find.byType(LiveSessionRing), findsOneWidget);
    });

    testWidgets('이번 주 공부 시간이 표시된다', (tester) async {
      await pumpScreen(tester, _studying);
      expect(find.text('16h 20m'), findsOneWidget);
      expect(find.text('이번 주'), findsOneWidget);
    });

    testWidgets('응원 보내기 버튼이 표시된다', (tester) async {
      await pumpScreen(tester, _studying);
      expect(find.text('응원 보내기'), findsOneWidget);
    });

    testWidgets('오프라인 친구는 OFFLINE 라벨이 표시된다', (tester) async {
      await pumpScreen(tester, _offline);
      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.text('오프라인'), findsOneWidget);
    });
  });
}
