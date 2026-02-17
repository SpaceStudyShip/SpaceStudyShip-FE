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

// === 통계 Providers ===

DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 오늘 공부 시간 (분)
@riverpod
int todayStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final today = _normalizeDate(DateTime.now());

  return sessions
      .where((s) => _normalizeDate(s.startedAt) == today)
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 이번 주 공부 시간 (분) — 최근 7일
@riverpod
int weeklyStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final now = DateTime.now();
  final weekStart = _normalizeDate(now.subtract(const Duration(days: 6)));

  return sessions
      .where((s) => !_normalizeDate(s.startedAt).isBefore(weekStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 연속 공부 일수 (streak)
@riverpod
int currentStreak(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  if (sessions.isEmpty) return 0;

  // 세션이 있는 날짜 집합
  final studyDates = sessions
      .map((s) => _normalizeDate(s.startedAt))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 최신순

  if (studyDates.isEmpty) return 0;

  final today = _normalizeDate(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  // 오늘 또는 어제 공부하지 않았으면 streak 0
  if (studyDates.first != today && studyDates.first != yesterday) return 0;

  int streak = 1;
  for (int i = 1; i < studyDates.length; i++) {
    final diff = studyDates[i - 1].difference(studyDates[i]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
