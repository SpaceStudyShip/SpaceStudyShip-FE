import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_filter.dart';

void main() {
  group('TimerSessionFilter', () {
    test('기본값: page=0, size=20, 나머지 null', () {
      const f = TimerSessionFilter();
      expect(f.page, 0);
      expect(f.size, 20);
      expect(f.startDate, isNull);
      expect(f.endDate, isNull);
      expect(f.todoId, isNull);
    });

    test('필드 지정 가능', () {
      final f = TimerSessionFilter(
        startDate: DateTime.utc(2026, 5, 1),
        endDate: DateTime.utc(2026, 5, 31),
        todoId: 'todo-1',
        page: 2,
        size: 50,
      );
      expect(f.page, 2);
      expect(f.size, 50);
      expect(f.todoId, 'todo-1');
    });
  });
}
