import '../../domain/entities/timer_session_entity.dart';
import '../../domain/entities/timer_session_create_result.dart';
import '../../domain/entities/timer_session_filter.dart';
import '../../domain/entities/timer_session_page.dart';
import '../../domain/entities/today_stats.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../datasources/timer_session_local_datasource.dart';
import '../models/timer_session_model.dart';

/// 게스트 전용 Local Repository. SharedPreferences 캐시만 사용한다.
class LocalTimerSessionRepositoryImpl implements TimerSessionRepository {
  final TimerSessionLocalDataSource _localDataSource;

  LocalTimerSessionRepositoryImpl(this._localDataSource);

  @override
  List<TimerSessionEntity> getSessions() {
    return _localDataSource.getSessions().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addSession(TimerSessionEntity session) async {
    await _localDataSource.addSession(session.toModel());
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }

  @override
  Future<TimerSessionCreateResult> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
    String? todoId,
    String? todoTitle,
    required String idempotencyKey,
  }) {
    throw UnsupportedError(
      'Guest mode uses local stop() logic. '
      'Notifier should call this only when isAuthenticated == true.',
    );
  }

  @override
  Future<TimerSessionPage> getSessionsPage(TimerSessionFilter filter) {
    throw UnsupportedError(
      'Guest mode reads sessions via getSessions(). '
      'Pagination is server-backed only.',
    );
  }

  @override
  Future<TodayStats> getTodayStats() {
    throw UnsupportedError(
      'Guest mode computes today stats locally in the notifier.',
    );
  }
}
