import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_page.dart';

void main() {
  group('TimerSessionPage', () {
    final session = TimerSessionEntity(
      id: 's1',
      startedAt: DateTime.utc(2026, 5, 25),
      endedAt: DateTime.utc(2026, 5, 25, 1),
      durationMinutes: 60,
    );

    test('필드를 보유한다', () {
      final page = TimerSessionPage(
        items: [session],
        page: 0,
        size: 20,
        totalElements: 1,
        totalPages: 1,
      );
      expect(page.items, [session]);
      expect(page.totalPages, 1);
    });

    test('hasNext: page < totalPages - 1', () {
      expect(
        TimerSessionPage(
          items: const [],
          page: 0,
          size: 20,
          totalElements: 60,
          totalPages: 3,
        ).hasNext,
        isTrue,
      );
      expect(
        TimerSessionPage(
          items: const [],
          page: 2,
          size: 20,
          totalElements: 60,
          totalPages: 3,
        ).hasNext,
        isFalse,
      );
      expect(
        TimerSessionPage(
          items: const [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ).hasNext,
        isFalse,
      );
    });
  });
}
