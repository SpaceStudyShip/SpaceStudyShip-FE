import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/timer_session_local_datasource.dart';
import '../../data/repositories/timer_session_repository_impl.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/repositories/timer_session_repository.dart';

part 'timer_session_provider.g.dart';

// === DataSource & Repository ===

@riverpod
TimerSessionLocalDataSource timerSessionLocalDataSource(Ref ref) {
  throw StateError(
    'TimerSessionLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
TimerSessionRepository timerSessionRepository(Ref ref) {
  final dataSource = ref.watch(timerSessionLocalDataSourceProvider);
  return TimerSessionRepositoryImpl(dataSource);
}

// === Session List ===

@riverpod
class TimerSessionListNotifier extends _$TimerSessionListNotifier {
  @override
  List<TimerSessionEntity> build() {
    final repository = ref.watch(timerSessionRepositoryProvider);
    return repository.getSessions();
  }

  Future<void> addSession(TimerSessionEntity session) async {
    final repository = ref.read(timerSessionRepositoryProvider);
    await repository.addSession(session);
    state = repository.getSessions();
  }
}

// === 날짜별 그룹화 (페이지네이션용) ===

DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 날짜별 세션 그룹 (페이지네이션 아이템 단위)
class DateGroup {
  final DateTime date;
  final List<TimerSessionEntity> sessions;
  final int totalMinutes;

  DateGroup({required this.date, required this.sessions})
    : totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 세션을 날짜별로 그룹화 (최신순 정렬)
@riverpod
List<DateGroup> sortedDateGroups(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final grouped = <DateTime, List<TimerSessionEntity>>{};

  for (final session in sessions) {
    final date = _normalizeDate(session.startedAt);
    grouped.putIfAbsent(date, () => []).add(session);
  }

  // 각 그룹 내부: 최신 시작 시간 순
  for (final list in grouped.values) {
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // 날짜 최신순 정렬
  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

  return sortedKeys
      .map((date) => DateGroup(date: date, sessions: grouped[date]!))
      .toList();
}
