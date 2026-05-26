import '../entities/timer_session_entity.dart';
import '../entities/timer_session_create_result.dart';
import '../entities/timer_session_filter.dart';
import '../entities/timer_session_page.dart';
import '../entities/today_stats.dart';

abstract class TimerSessionRepository {
  // === 게스트 (LocalTimerSessionRepositoryImpl) 가 구현 ===

  /// 세션 동기 조회 (게스트 전용).
  List<TimerSessionEntity> getSessions();

  /// 세션 로컬 저장 (게스트 전용).
  Future<void> addSession(TimerSessionEntity session);

  /// 로컬 캐시 전체 삭제.
  Future<void> clearAll();

  // === 인증 (TimerSessionRepositoryImpl) 가 구현 ===

  /// POST /api/timer-sessions — 세션 저장 + 연료 자동 충전.
  ///
  /// [idempotencyKey] 동일 키 재요청 시 서버가 기존 세션 반환 (중복 충전 방지).
  /// 400 5종 → TimerSessionException 서브타입 throw.
  /// 404 TODO_NOT_FOUND → [LinkedTodoNotFound] throw (호출부에서 todoId 빼고 재시도).
  Future<TimerSessionCreateResult> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
    String? todoId,
    String? todoTitle,
    required String idempotencyKey,
  });

  /// GET /api/timer-sessions — 페이지네이션 조회.
  Future<TimerSessionPage> getSessionsPage(TimerSessionFilter filter);

  /// GET /api/timer-sessions/today-stats — KST 기준 오늘 통계.
  Future<TodayStats> getTodayStats();
}
