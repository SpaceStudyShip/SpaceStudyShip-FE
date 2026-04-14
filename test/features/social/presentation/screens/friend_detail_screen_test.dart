import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:space_study_ship/features/settings/data/providers/settings_data_providers.dart';
import 'package:space_study_ship/features/social/domain/entities/friend_entity.dart';
import 'package:space_study_ship/features/social/presentation/screens/friend_detail_screen.dart';

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
        settingsLocalDataSourceProvider
            .overrideWithValue(_settingsDataSource),
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

  group('FriendDetailScreen', () {
    testWidgets('친구 이름이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('김우주'), findsOneWidget);
    });

    testWidgets('공부 중 친구는 현재 과목이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('수학'), findsOneWidget);
    });

    testWidgets('오늘 공부 시간이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('2h 14m'), findsAtLeast(1));
    });

    testWidgets('이번 주 공부 시간이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _studying)));
      await tester.pump();
      expect(find.text('16h 20m'), findsOneWidget);
    });

    testWidgets('오프라인 친구는 과목 카드가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(_wrap(FriendDetailScreen(friend: _offline)));
      await tester.pump();
      expect(find.text('현재 과목'), findsNothing);
    });
  });
}
